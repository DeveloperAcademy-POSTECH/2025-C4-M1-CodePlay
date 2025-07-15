//
//  PosterViewModel.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/11/25.
//
import Foundation
import UIKit
internal import Combine

// MARK: PosterViewModelInput
protocol PosterViewModelInput {
    /// 페스티벌 이미지를 인식하는 함수
    func recongizeFestivalLineup(from images: [UIImage])
    /// 텍스트 초기화 함수
    func clearText()
}

// MARK: PosterViewModelOutput
protocol PosterViewModelOutput {
    var rawText: Observable<RawText?> { get }
}

// MARK: PosterViewModel
protocol PosterViewModel: PosterViewModelInput, PosterViewModelOutput, ObservableObject { }

// MARK: DefaultMainViewModel
final class DefaultPosterViewModel: PosterViewModel {
    var rawText: Observable<RawText?> = Observable(nil)
    private let scanPosterUseCase: ScanPosterUseCase
    
    init(scanPosterUseCase: ScanPosterUseCase) {
        self.scanPosterUseCase = scanPosterUseCase
    }
    
    func recongizeFestivalLineup(from images: [UIImage]) {
        Task {
            let result = try await scanPosterUseCase.execute(with: images)
            await MainActor.run {
                self.rawText.value = result
            }
        }
    }
    
    func clearText() {
        rawText.value = nil
    }
}
