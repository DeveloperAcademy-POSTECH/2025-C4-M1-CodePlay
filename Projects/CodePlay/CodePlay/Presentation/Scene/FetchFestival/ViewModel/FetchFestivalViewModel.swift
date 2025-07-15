//
//  FetchFestivalViewModel.swift
//  CodePlay
//
//  Created by 성현 on 7/15/25.
//
import Foundation
import UIKit
internal import Combine

// MARK: MainViewModelInput
protocol FetchFestivalViewModelInput {
    /// 페스티벌 이미지를 인식하는 함수
    func recongizeFestivalLineup(from images: [UIImage])
    /// 텍스트 초기화 함수
    func clearText()
}

// MARK: MainViewModelOutput
protocol FetchFestivalViewModelOutput {
    var rawText: Observable<RawText?> { get }
}

// MARK: MainViewModel
protocol FetchFestivalViewModel: FetchFestivalViewModelInput, FetchFestivalViewModelOutput, ObservableObject { }

// MARK: DefaultMainViewModel
final class DefaultFetchFestivalViewModel: FetchFestivalViewModel {
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
