//
//  DefaultRecognizeTextUseCase.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/11/25.
//

import Vision
import UIKit

final class DefaultRecognizeTextUseCase: RecognizeTextUseCase {
    func execute(with images: [UIImage]) async throws -> RawText {
        var fullText = ""
        
        for image in images {
            guard let cgImage = image.cgImage else { continue }
            
            let request = VNRecognizeTextRequest()
            request.recognitionLanguages = ["ko"]
            request.usesLanguageCorrection = true
            
            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            try handler.perform([request])
            
            let observations = request.results ?? []
            let text = observations
                .compactMap { $0.topCandidates(1).first?.string }
                .joined(separator: "\n")
            
            fullText += text + "\n"
        }
        
        return RawText(text: fullText)
    }
}
