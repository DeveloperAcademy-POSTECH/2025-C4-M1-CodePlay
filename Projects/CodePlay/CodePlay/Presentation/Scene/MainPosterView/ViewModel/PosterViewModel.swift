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
    var scannedText: Observable<RawText?> { get set }
    var shouldNavigateToFestivalCheck: Observable<Bool> { get set }
    var shouldNavigateToMakePlaylist: Observable<Bool> { get set }
}

// MARK: PosterViewModel - UseCase 호출 및 모델 업데이트
protocol PosterViewModel: PosterViewModelInput, PosterViewModelOutput,
    ObservableObject
{}

// MARK: DefaultMainViewModel
class DefaultPosterViewModel: PosterViewModel {
    @Published var scannedText: Observable<RawText?> = Observable(nil)
    @Published var shouldNavigateToFestivalCheck = Observable<Bool>(false)
    @Published var shouldNavigateToMakePlaylist = Observable<Bool>(false)
    
    private let scanPosterUseCase: ScanPosterUseCase

    init(scanPosterUseCase: ScanPosterUseCase) {
        self.scanPosterUseCase = scanPosterUseCase
    }

    func recongizeFestivalLineup(from images: [UIImage]) {
        Task {
            do {
                let rawText = try await scanPosterUseCase.execute(with: images)
                await MainActor.run {
                    self.scannedText.value = rawText
                    self.shouldNavigateToFestivalCheck.value = true
                }
            } catch {
                Log.fault("[PosterViewModel] - 포스터 인식 실패:\(error)")
            }
        }
    }

    func clearText() {
        scannedText.value = nil
        shouldNavigateToFestivalCheck.value = false
    }
}
