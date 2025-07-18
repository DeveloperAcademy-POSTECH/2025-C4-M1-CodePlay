//
//  File.swift
//  CodePlay
//
//  Created by 성현 on 7/15/25.
//

protocol ExportPlaylistUseCase {
    func preProcessRawText(_ rawText: RawText) -> [String]
    func searchArtists(from rawText: RawText) async -> [ArtistMatch]
    func searchTopSongs()
}

final class DefaultExportPlaylistUseCase: ExportPlaylistUseCase {
    private let repository: ExportPlaylistRepository

    init(repository: ExportPlaylistRepository) {
        self.repository = repository
    }

    func preProcessRawText(_ rawText: RawText) -> [String] {
        return repository.prepareArtistCandidates(from: rawText)
    }

    func searchArtists(from rawText: RawText) async -> [ArtistMatch] {
        return await repository.searchArtists(from: rawText)
    }

    func searchTopSongs() {
        // TODO
    }
}

