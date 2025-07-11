//
//  MainViewModel.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/11/25.
//

import Foundation
import UIKit
internal import Combine

// MARK: MainViewModelInput
protocol MainViewModelInput {
    /// 페스티벌 이미지를 인식하는 함수
    func recongizeFestivalLineup(from images: [UIImage])
    /// 텍스트 초기화 함수
    func clearText()
}

// MARK: MainViewModelOutput
protocol MainViewModelOutput {
    var rawText: RawText? { get }
}

// MARK: MainViewModel
protocol MainViewModel: MainViewModelInput, MainViewModelOutput { }

// MARK: DefaultMainViewModel
final class DefaultMainViewModel: MainViewModel, ObservableObject {
    
    @Published var text = ""
    var rawText: RawText?
    private let recognizeTextUseCase: RecognizeTextUseCase
    
    init(text: String = "", rawText: RawText? = nil, recognizeTextUseCase: RecognizeTextUseCase) {
        self.text = text
        self.rawText = rawText
        self.recognizeTextUseCase = recognizeTextUseCase
    }
    
    func recongizeFestivalLineup(from images: [UIImage]) {
        Task {
            let result = try await recognizeTextUseCase.execute(with: images)
            await MainActor.run {
                self.rawText = result
            }
        }
    }
    
    func clearText() {
        rawText = nil
    }
}

