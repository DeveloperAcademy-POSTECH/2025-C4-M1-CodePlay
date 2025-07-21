//
//  CheckLicenseRepository.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/12/25.
//

import UIKit
import Vision

protocol ScanPosterRepository {
    func execute(with images: [UIImage]) async throws -> FestivalInfo
}

final class DefaultScanPosterRepository: ScanPosterRepository {
    func execute(with images: [UIImage]) async throws -> FestivalInfo {
        var fullText = ""

        for image in images {
            guard let cgImage = image.cgImage else { continue }

            let request = VNRecognizeTextRequest()
            request.recognitionLanguages = ["ko"]
            request.usesLanguageCorrection = true

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try handler.perform([request])

            let observations = request.results ?? []
            let text =
                observations
                .compactMap { $0.topCandidates(1).first?.string }
                .joined(separator: "\n")

            fullText += text + "\n"
        }
        let rawText = RawText(text: fullText)
        let parsed = parseFestivalInfo(from: rawText)
        print(rawText.text)
        return parsed
    }

    /// 정규식이나 필터링 로직을 담는 함수
    private func parseFestivalInfo(from raw: RawText) -> FestivalInfo {
        // TODO: 필터링 로직 구현시 수정예정
        return FestivalInfo(
            id: raw.id,
            date: raw.text,
            title: raw.text,
            subtitle: raw.text
        )
    }
}
