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
}


final class DefaultExportPlaylistRepository: ExportPlaylistRepository {    
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
        var allMatches: [ArtistMatch] = []

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
                    allMatches.append(match)
                }
            } catch {
                print("❌ 검색 실패: \(name) → \(error)")
            }
        }

        // 중복 제거 (appleMusicId 기준)
        let uniqueMatches = Dictionary(grouping: allMatches, by: \.appleMusicId)
            .compactMap { $0.value.first }

        return uniqueMatches
    }
}
