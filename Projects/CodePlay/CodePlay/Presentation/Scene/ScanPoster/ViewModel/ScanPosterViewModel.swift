//
//  ScanPosterViewModel.swift
//  CodePlay
//
//  Created by 성현 on 7/15/25.
//

import Foundation
internal import Combine

final class ScanPosterViewModel: ObservableObject {
    @Published var scannedText: RawText?
    
    private let scanPosterUseCase: ScanPosterUseCase

    init(scanPosterUseCase: ScanPosterUseCase) {
        self.scanPosterUseCase = scanPosterUseCase
    }

    func updateRecognizedText(_ text: String) {
        self.scannedText = RawText(text: text)
    }
}

