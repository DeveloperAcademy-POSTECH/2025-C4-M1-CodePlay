//
//  CheckLicenseRepository.swift
//  CodePlay
//
//  Created by 성현 on 7/15/25.
//

import Foundation
import MusicKit
import SwiftData

// Apple Music 기반의 아티스트 탐색 및 플레이리스트 생성 기능을 담당하는 Repository 프로토콜
protocol ExportPlaylistRepository {
    func prepareArtistCandidates(from rawText: RawText) -> [String]
    func searchArtists(from rawText: RawText) async -> [ArtistMatch]
    func searchTopSongs(for artists: [ArtistMatch]) async -> [PlaylistEntry]
    func searchTopSongsWithCaching(for artists: [ArtistMatch], musicPlayerUseCase: MusicPlayerUseCase) async -> [PlaylistEntry]
    func savePlaylist(title: String, entries: [PlaylistEntry]) async throws -> Playlist
    func clearTemporaryData()
    func exportPlaylistToAppleMusic(title: String, trackIds: [String]) async throws
    func deletePlaylistEntry(trackId: String) async
}

// 기본 구현체: OCR 텍스트 → 아티스트 후보 추출 → Apple Music에서 탐색 및 플레이리스트 생성
final class DefaultExportPlaylistRepository: ExportPlaylistRepository {
    private var temporaryMatches: [ArtistMatch] = [] // 임시 검색 결과 (메모리 캐시용)

    private let modelContext: ModelContext
    private let am: AppleMusicAPIServiceProtocol
    private let storefront: String

    init(modelContext: ModelContext,
         am: AppleMusicAPIServiceProtocol,
         storefront: String = "kr") {
        self.modelContext = modelContext
        self.am = am
        self.storefront = storefront
    }
    
    // OCR 텍스트에서 아티스트 후보 단어 조합을 생성
    func prepareArtistCandidates(from rawText: RawText) -> [String] {
        let lines = rawText.text.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty && !shouldSkipLine($0) }

        var candidates: [String] = []

        for line in lines {
            let words = line.components(separatedBy: .whitespaces)
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }

            // 1~3단어 조합으로 후보 생성
            for i in 0..<words.count {
                for len in 1...min(3, words.count - i) {
                    let chunk = words[i..<i+len].joined(separator: " ")
                    candidates.append(chunk)
                }
            }
        }

        return candidates
    }

    // 검색에서 제외할 특정 문자열/패턴 필터링
    private func shouldSkipLine(_ line: String) -> Bool {
        let lower = line.lowercased()
        let skipPhrases = [
            "tokyo marine stadium", "summer sonic", "main stage",
            "line up", "festival", "live nation", "olympic stadium",
            "tokyo station", "marine arena", "confirmed", "2025", "july", "august", "september"
        ]

        return skipPhrases.contains(where: { lower.contains($0) }) ||
               lower.range(of: #"\d{4}|\d{1,2}[-./ ]\d{1,2}"#, options: .regularExpression) != nil
    }
    
    // 후보 이름을 기반으로 Apple Music에서 아티스트 검색
    func searchArtists(from rawText: RawText) async -> [ArtistMatch] {
            let names = rawText.text
                .components(separatedBy: ",")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }

            var matches: [ArtistMatch] = []
            for name in names {
                do {
                    let dto = try await am.searchArtists(term: name, limit: 1, storefront: storefront)
                    if let artist = dto.results?.artists?.data?.first {
                        matches.append(
                            ArtistMatch(
                                rawText: rawText.text,
                                artistName: artist.attributes?.name ?? name,
                                appleMusicId: artist.id,
                                profileArtworkUrl: artist.attributes?.artwork?.url?
                                    .replacingOccurrences(of: "{w}", with: "300")
                                    .replacingOccurrences(of: "{h}", with: "300") ?? "",
                                createdAt: .now
                            )
                        )
                    }
                } catch {
                    // 네 공용 로거로 찍어라
                }
            }
            return matches
        }

    // 각 아티스트에 대해 상위 3곡을 Apple Music에서 검색 후 PlaylistEntry로 변환
    func searchTopSongs(for artists: [ArtistMatch]) async -> [PlaylistEntry] {
        var entries: [PlaylistEntry] = []
        for a in artists {
            do {
                let dto = try await am.topSongs(artistId: a.appleMusicId, limit: 3, storefront: storefront)
                for s in dto.data {
                    let artURL = s.attributes?.artwork?.url?
                        .replacingOccurrences(of: "{w}", with: "300")
                        .replacingOccurrences(of: "{h}", with: "300") ?? ""
                    let preview = s.attributes?.previews?.first?.url.absoluteString ?? ""
                    entries.append(
                        PlaylistEntry(
                            id: UUID(), playlistId: UUID(),
                            artistMatchId: a.id, artistName: a.artistName,
                            appleMusicId: a.appleMusicId,
                            trackTitle: s.attributes?.name ?? "Unknown",
                            trackId: s.id,
                            trackPreviewUrl: preview,
                            profileArtworkUrl: a.profileArtworkUrl,
                            albumArtworkUrl: artURL,
                            albumName: s.attributes?.albumName ?? "Unknown Album",
                            createdAt: .now
                        )
                    )
                }
            } catch {
                Log.debug("❌ [REST TopSongs 실패] \(a.artistName) (\(a.appleMusicId)): \(error)")
            }
        }
        return entries
    }

    
    // 캐싱과 함께 각 아티스트에 대해 상위 3곡을 Apple Music에서 검색 후 PlaylistEntry로 변환
    func searchTopSongsWithCaching(for artists: [ArtistMatch],
                                       musicPlayerUseCase: MusicPlayerUseCase) async -> [PlaylistEntry] {
            var entries: [PlaylistEntry] = []
            for a in artists {
                do {
                    let dto = try await am.topSongs(artistId: a.appleMusicId, limit: 3, storefront: storefront)
                    for s in dto.data {
                        let artURL = s.attributes?.artwork?.url?
                            .replacingOccurrences(of: "{w}", with: "300")
                            .replacingOccurrences(of: "{h}", with: "300") ?? ""
                        let preview = s.attributes?.previews?.first?.url.absoluteString ?? ""

                        entries.append(
                            PlaylistEntry(
                                id: UUID(), playlistId: UUID(),
                                artistMatchId: a.id, artistName: a.artistName,
                                appleMusicId: a.appleMusicId,
                                trackTitle: s.attributes?.name ?? "Unknown",
                                trackId: s.id,
                                trackPreviewUrl: preview,
                                profileArtworkUrl: a.profileArtworkUrl,
                                albumArtworkUrl: artURL,
                                albumName: s.attributes?.albumName ?? "Unknown Album",
                                createdAt: .now
                            )
                        )
                    }
                } catch {
                    // 로깅
                }
            }
            return entries
        }



    // 영구 저장소에 Playlist 및 해당 Entry 저장
    @MainActor
    func savePlaylist(title: String, entries: [PlaylistEntry]) async throws -> Playlist {
        let playlistId = UUID()
        let playlist = Playlist(id: playlistId, title: title, createdAt: .now)

        // 각 entry에 playlistId 바인딩
        for entry in entries {
            entry.playlistId = playlistId
        }

        try modelContext.insert(playlist)
        for entry in entries {
            try modelContext.insert(entry)
        }

        try modelContext.save()
        return playlist
    }

    // 임시 검색 결과 초기화
    func clearTemporaryData() {
        temporaryMatches = []
    }

    // Apple Music 계정에 플레이리스트 생성 및 곡 추가
    func exportPlaylistToAppleMusic(title: String, trackIds: [String]) async throws {
        let musicItemIDs = trackIds.map { MusicItemID($0) }
        
        let status = await MusicAuthorization.currentStatus
        let granted = (status == .authorized) ? status : await MusicAuthorization.request()
        guard granted == .authorized else {
            throw NSError(domain: "ExportPlaylistError", code: 1000,
                          userInfo: [NSLocalizedDescriptionKey: "Apple Music 권한이 필요합니다."])
        }

        // Apple Music에서 곡 정보 조회
        let request = MusicCatalogResourceRequest<Song>(matching: \.id, memberOf: musicItemIDs)
        let response = try await request.response()
        let songs = response.items

        guard !songs.isEmpty else {
            throw NSError(
                domain: "ExportPlaylistError",
                code: 1001,
                userInfo: [NSLocalizedDescriptionKey: "Apple Music에서 곡 정보를 찾을 수 없습니다."]
            )
        }

        let songCollection = MusicItemCollection(songs)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let dateString = dateFormatter.string(from: Date())

        // Apple Music 라이브러리에 플레이리스트 생성
        let createdPlaylist = try await MusicLibrary.shared.createPlaylist(
            name: title,
            description: "\(dateString)",
            items: songCollection
        )
    }
    
    func deletePlaylistEntry(trackId: String) async {
        await MainActor.run {
            do {
                let predicate = #Predicate<PlaylistEntry> { $0.trackId == trackId }
                let descriptor = FetchDescriptor<PlaylistEntry>(predicate: predicate)
                
                if let entry = try modelContext.fetch(descriptor).first {
                    modelContext.delete(entry)
                    try modelContext.save()
                } else {
                }
            } catch {
            }
        }
    }
}

// 추후에 어디로 빼야할지 고민해보겠읍니다.
extension String {
    func amArtworkURL(width: Int, height: Int) -> URL? {
        self.replacingOccurrences(of: "{w}", with: "\(width)")
            .replacingOccurrences(of: "{h}", with: "\(height)")
            .pipe(URL.init(string:))
    }
}
private extension String {
    func pipe<T>(_ f: (String) -> T?) -> T? { f(self) }
}

