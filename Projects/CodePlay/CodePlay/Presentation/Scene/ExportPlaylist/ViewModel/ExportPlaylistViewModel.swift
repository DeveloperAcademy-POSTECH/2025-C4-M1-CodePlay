    //
    //  ExportPlaylistViewModel.swift
    //  CodePlay
    //
    //  Created by 성현 on 7/15/25.
    //
    import Foundation
    import SwiftData

    protocol ExportPlaylistViewModel {
        func preProcessRawText(_ rawText: RawText) // 텍스트를 띄어쓰기에 맞춰서 여러개 쪼개고, 하나의 데이터로 저장하는 로직 (RawText 업데이트)
        var artistCandidates: Observable<[String]> { get } // 아티스트 스트링 관리, 추후 리펙토링 필요
        func searchArtists(from rawText: RawText) async -> [ArtistMatch] // RawText를 한줄한줄 검색해 매칭된 아티스트 저장
        func searchTopSongs(from rawText: RawText, artistMatches: [ArtistMatch]) async -> [PlaylistEntry] // ArtistMatch에서 노래를 검색하고, PlaylistEntry로 저장
        func exportLatestPlaylistToAppleMusic() async // 애플뮤직으로 플레이리스트 전송
    }

    final class DefaultExportPlaylistViewModel: ExportPlaylistViewModel {
        private let useCase: ExportPlaylistUseCase
        private let modelContext: ModelContext

        var artistCandidates: Observable<[String]> = Observable([])

        init(useCase: ExportPlaylistUseCase, modelContext: ModelContext) {
            self.useCase = useCase
            self.modelContext = modelContext
        }

        func preProcessRawText(_ rawText: RawText) {
            let candidates = useCase.preProcessRawText(rawText)
            artistCandidates.value = candidates
        }

        func searchArtists(from rawText: RawText) async -> [ArtistMatch] {
            await useCase.searchArtists(from: rawText)
        }

        func searchTopSongs(from rawText: RawText, artistMatches: [ArtistMatch]) async -> [PlaylistEntry] {
            (try? await useCase.searchTopSongs(from: rawText, artistMatches: artistMatches)) ?? []
        }
        
        func exportLatestPlaylistToAppleMusic() async { // 추후 Repository로 이동해야할 듯 합니다.
            await MainActor.run {
                do {
                    guard let latest = try? modelContext.fetch(FetchDescriptor<Playlist>()).last else {
                        print("❌ Playlist 없음")
                        return
                    }

                    let playlistId = latest.id
                    let entries = try modelContext.fetch(FetchDescriptor<PlaylistEntry>(
                        predicate: #Predicate { $0.playlistId == playlistId }
                    ))

                    Task {
                        try await useCase.exportToAppleMusic(playlist: latest, entries: entries)
                        print("✅ Apple Music 전송 완료")
                    }
                } catch {
                    print("❌ 전송 실패: \(error.localizedDescription)")
                }
            }
        }
    }
