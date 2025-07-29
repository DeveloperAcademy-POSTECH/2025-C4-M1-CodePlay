//
//  File.swift
//  CodePlay
//
//  Created by 성현 on 7/15/25.
//
import Foundation
import MusicKit

protocol ExportPlaylistUseCase {
    func preProcessRawText(_ rawText: RawText) -> [String]
    func searchArtists(from rawText: RawText) async -> [ArtistMatch]
    func searchTopSongs(from rawText: RawText, artistMatches: [ArtistMatch]) async throws -> [PlaylistEntry]
    func searchTopSongsWithCaching(from rawText: RawText, artistMatches: [ArtistMatch], musicPlayerUseCase: MusicPlayerUseCase) async throws -> [PlaylistEntry]
    func exportToAppleMusic(playlist: Playlist, entries: [PlaylistEntry]) async throws
    func deletePlaylistEntry(trackId: String) async
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

    func searchTopSongs(from rawText: RawText, artistMatches: [ArtistMatch]) async throws -> [PlaylistEntry] {
        let title = rawText.text.components(separatedBy: .newlines).first ?? "My Playlist"
        let entries = await repository.searchTopSongs(for: artistMatches)

        try await repository.savePlaylist(title: title, entries: entries)
        repository.clearTemporaryData()

        return entries
    }
    
    func searchTopSongsWithCaching(from rawText: RawText, artistMatches: [ArtistMatch], musicPlayerUseCase: MusicPlayerUseCase) async throws -> [PlaylistEntry] {
        let title = rawText.text.components(separatedBy: .newlines).first ?? "My Playlist"
        let entries = await repository.searchTopSongsWithCaching(for: artistMatches, musicPlayerUseCase: musicPlayerUseCase)

        try await repository.savePlaylist(title: title, entries: entries)
        repository.clearTemporaryData()

        return entries
    }

    func exportToAppleMusic(playlist: Playlist, entries: [PlaylistEntry]) async throws {
        let trackIds = entries.map { $0.trackId }
        try await repository.exportPlaylistToAppleMusic(title: playlist.title, trackIds: trackIds)
    }

    func deletePlaylistEntry(trackId: String) async {
        await repository.deletePlaylistEntry(trackId: trackId)
    }
}

