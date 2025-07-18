//
//  CheckLicenseRepository.swift
//  CodePlay
//
//  Created by 성현 on 7/15/25.
//
import Foundation
import MusicKit
import SwiftData

protocol ExportPlaylistRepository {
    func prepareArtistCandidates(from rawText: RawText) -> [String]
    func searchArtists(from rawText: RawText) async -> [ArtistMatch]
    func searchTopSongs(for artists: [ArtistMatch]) async -> [PlaylistEntry]
    func savePlaylist(title: String, entries: [PlaylistEntry]) async throws
    func clearTemporaryData()
}

final class DefaultExportPlaylistRepository: ExportPlaylistRepository {
    private var temporaryMatches: [ArtistMatch] = []

    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    func prepareArtistCandidates(from rawText: RawText) -> [String] {
        let lines = rawText.text.components(separatedBy: .newlines)
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty && !shouldSkipLine($0) }

        var candidates: [String] = []

        for line in lines {
            let words = line.components(separatedBy: .whitespaces)
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                .filter { !$0.isEmpty }

            for i in 0..<words.count {
                for len in 1...min(3, words.count - i) {
                    let chunk = words[i..<i+len].joined(separator: " ")
                    candidates.append(chunk)
                }
            }
        }

        return candidates
    }

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
                    print("❌ 검색 실패: \(name) → \(error)")
                }
            }

            // 중복 제거 후 저장
            let uniqueMatches = Dictionary(grouping: results, by: \.appleMusicId)
                .compactMap { $0.value.first }

            temporaryMatches = uniqueMatches
            return uniqueMatches
        }

    func searchTopSongs(for artists: [ArtistMatch]) async -> [PlaylistEntry] {
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

                    let trackPreviewUrl: String
                    if let preview = song.previewAssets?.first?.url {
                        trackPreviewUrl = preview.absoluteString
                    } else {
                        trackPreviewUrl = ""
                    }

                    let albumArtworkUrl: String
                    if let url = song.artwork?.url(width: 300, height: 300) {
                        albumArtworkUrl = url.absoluteString
                    } else {
                        albumArtworkUrl = ""
                    }

                    let entry = PlaylistEntry(
                        id: UUID(),
                        playlistId: UUID(), // 이후 savePlaylist에서 바인딩
                        artistMatchId: artist.id,
                        artistName: artist.artistName,
                        appleMusicId: artist.appleMusicId,
                        trackTitle: trackTitle,
                        trackId: trackId,
                        trackPreviewUrl: trackPreviewUrl,
                        profileArtworkUrl: artist.profileArtworkUrl,
                        albumArtworkUrl: albumArtworkUrl,
                        createdAt: .now
                    )

                    allEntries.append(entry)
                }
            } catch {
                print("❌ \(artist.artistName) 인기곡 검색 실패: \(error)")
            }
        }

        return allEntries
    }

    @MainActor
    func savePlaylist(title: String, entries: [PlaylistEntry]) async throws {
        let playlistId = UUID()
        let playlist = Playlist(id: playlistId, title: title, createdAt: .now)

        for entry in entries {
            entry.playlistId = playlistId
        }

        try modelContext.insert(playlist)
        for entry in entries {
            try modelContext.insert(entry)
        }

        try modelContext.save()
    }

    func clearTemporaryData() {
        temporaryMatches = []
    }
}
