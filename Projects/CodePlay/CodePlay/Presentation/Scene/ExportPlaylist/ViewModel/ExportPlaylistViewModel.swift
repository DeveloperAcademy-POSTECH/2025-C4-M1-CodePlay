//
//  ExportPlaylistViewModel.swift
//  CodePlay
//
//  Created by 성현 on 7/15/25.
//
import Foundation

protocol ExportPlaylistViewModel {
    func preProcessRawText(_ rawText: RawText)
    func searchArtists(from rawText: RawText) async -> [ArtistMatch]
    func searchTopSongs(from rawText: RawText, artistMatches: [ArtistMatch]) async -> [PlaylistEntry]
    var artistCandidates: Observable<[String]> { get }
}

final class DefaultExportPlaylistViewModel: ExportPlaylistViewModel {
    private let useCase: ExportPlaylistUseCase

    var artistCandidates: Observable<[String]> = Observable([])

    init(useCase: ExportPlaylistUseCase) {
        self.useCase = useCase
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
}
