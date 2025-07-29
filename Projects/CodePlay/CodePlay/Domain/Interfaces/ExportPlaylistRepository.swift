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

    private let modelContext: ModelContext // SwiftData 모델 컨텍스트

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
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
        let candidates = prepareArtistCandidates(from: rawText)
        var results: [ArtistMatch] = []

        for name in candidates {
            do {
                var request = MusicCatalogSearchRequest(term: name, types: [Artist.self])
                request.limit = 1
                
                let response = try await request.response()

                if let artist = response.artists.first {
                    let match = ArtistMatch(
                        rawText: rawText.text,
                        artistName: artist.name,
                        appleMusicId: artist.id.rawValue,
                        profileArtworkUrl: artist.artwork?.url(width: 300, height: 300)?.absoluteString ?? "",
                        createdAt: .now
                    )
                    results.append(match)
                }
            } catch {
            }
        }

        // 중복 아티스트 제거 (appleMusicId 기준)
        let uniqueMatches = Dictionary(grouping: results, by: \.appleMusicId)
            .compactMap { $0.value.first }

        temporaryMatches = uniqueMatches
        return uniqueMatches
    }

    // 각 아티스트에 대해 상위 3곡을 Apple Music에서 검색 후 PlaylistEntry로 변환
    func searchTopSongs(for artists: [ArtistMatch]) async -> [PlaylistEntry] {
        var allEntries: [PlaylistEntry] = []

        for artist in artists {
            do {
                var request = MusicCatalogSearchRequest(term: artist.artistName, types: [Song.self])
                request.limit = 10
                let response = try await request.response()
                let topSongs = response.songs.prefix(3)

                print("🔍 [TopSongs] \(artist.artistName) - 검색된 곡 수: \(topSongs.count)")

                for song in topSongs {
                    let entry = PlaylistEntry(
                        id: UUID(),
                        playlistId: UUID(), // 추후 ViewModel에서 덮어씌움
                        artistMatchId: artist.id,
                        artistName: artist.artistName,
                        appleMusicId: artist.appleMusicId,
                        trackTitle: song.title,
                        trackId: song.id.rawValue,
                        trackPreviewUrl: song.previewAssets?.first?.url?.absoluteString ?? "",
                        profileArtworkUrl: artist.profileArtworkUrl,
                        albumArtworkUrl: song.artwork?.url(width: 300, height: 300)?.absoluteString ?? "",
                        albumName: song.albumTitle ?? "Unknown Album",
                        createdAt: .now
                    )

                    print("🎵 [Entry 생성됨] \(entry.artistName) - \(entry.trackTitle) (\(entry.trackId))")
                    allEntries.append(entry)
                }
            } catch {
                print("❌ [TopSongs 검색 실패] \(artist.artistName): \(error)")
            }
        }

        return allEntries
    }
    
    // 캐싱과 함께 각 아티스트에 대해 상위 3곡을 Apple Music에서 검색 후 PlaylistEntry로 변환
    func searchTopSongsWithCaching(for artists: [ArtistMatch], musicPlayerUseCase: MusicPlayerUseCase) async -> [PlaylistEntry] {
        var allEntries: [PlaylistEntry] = []

        for artist in artists {
            do {
                var request = MusicCatalogSearchRequest(term: artist.artistName, types: [Song.self])
                request.limit = 10
                let response = try await request.response()
                let topSongs = response.songs.prefix(3)

                for song in topSongs {
                    let trackId = song.id.rawValue
                    let trackTitle = song.title

                    let trackPreviewUrl: String = song.previewAssets?.first?.url?.absoluteString ?? ""
                    let albumArtworkUrl: String = song.artwork?.url(width: 300, height: 300)?.absoluteString ?? ""
                    let albumName = song.albumTitle ?? "Unknown Album"

                    let entry = PlaylistEntry(
                        id: UUID(),
                        playlistId: UUID(), // save 시 덮어씌움
                        artistMatchId: artist.id,
                        artistName: artist.artistName,
                        appleMusicId: artist.appleMusicId,
                        trackTitle: trackTitle,
                        trackId: trackId,
                        trackPreviewUrl: trackPreviewUrl,
                        profileArtworkUrl: artist.profileArtworkUrl,
                        albumArtworkUrl: albumArtworkUrl,
                        albumName: albumName,
                        createdAt: .now
                    )

                    allEntries.append(entry)
                    
                    // 백그라운드에서 음악 캐싱 수행
                    Task {
                        musicPlayerUseCase.cacheSong(song, for: trackId)
                        if song.previewAssets?.first?.url != nil {
                            await musicPlayerUseCase.preloadSongToMemory(song, for: trackId)
                        }
                    }
                }
            } catch {

            }
        }

        print("✅ [searchTopSongs] 총 생성된 Entry 수: \(allEntries.count)")
        return allEntries
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

        // Apple Music 라이브러리에 플레이리스트 생성
        let createdPlaylist = try await MusicLibrary.shared.createPlaylist(
            name: title,
            description: "CodePlay OCR 기반 자동 생성",
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
