//
//  CheckLicenseRepository.swift
//  CodePlay
//
//  Created by 성현 on 7/15/25.
//
import Foundation

protocol ExportPlaylistRepository {
    func prepareArtistCandidates(from rawText: RawText) -> [String]
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
}
