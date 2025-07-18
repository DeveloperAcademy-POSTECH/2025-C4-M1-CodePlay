//
//  ExportPlaylistViewModel.swift
//  CodePlay
//
//  Created by 성현 on 7/15/25.
//
import Foundation
import SwiftData

protocol ExportPlaylistViewModel {
    func preProcessRawText(_ rawText: RawText)
    func searchArtists(from rawText: RawText) async -> [ArtistMatch]
    func searchTopSongs(from rawText: RawText, artistMatches: [ArtistMatch]) async -> [PlaylistEntry]
    var artistCandidates: Observable<[String]> { get }
    func exportLatestPlaylistToAppleMusic() async
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
    
    func exportLatestPlaylistToAppleMusic() async {
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
