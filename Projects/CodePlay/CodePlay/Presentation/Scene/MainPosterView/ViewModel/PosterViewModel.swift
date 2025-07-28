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
    var festivalData: Observable<[PosterItemModel]> { get }
    var scannedText: Observable<RawText?> { get set }
    var shouldNavigateToMakePlaylist: Observable<Bool> { get set }
}

// MARK: PosterViewModel - UseCase 호출 및 모델 업데이트
protocol PosterViewModel: PosterViewModelInput, PosterViewModelOutput,
    ObservableObject
{}

// MARK: DefaultMainViewModel
class DefaultPosterViewModel: PosterViewModel {
    @Published var scannedText: Observable<RawText?> = Observable(nil)
    @Published var shouldNavigateToMakePlaylist = Observable<Bool>(false)
    var festivalData: Observable<[PosterItemModel]>
    
    private let scanPosterUseCase: ScanPosterUseCase

    init(scanPosterUseCase: ScanPosterUseCase) {
        self.scanPosterUseCase = scanPosterUseCase
        self.festivalData = Observable([])
    }

    func recongizeFestivalLineup(from images: [UIImage]) {
        Task {
            var newItems: [PosterItemModel] = []

            for image in images {
                do {
                    let info = try await scanPosterUseCase.execute(with: [image])
                    let item = PosterItemModel(
                        info: info,
                        imageURL: nil,
                        image: image
                    )  // TODO: imageURL 수정 예정
                    newItems.append(item)
                    
                    await MainActor.run {
                        self.shouldNavigateToMakePlaylist.value = true
                        self.scannedText.value = RawText(text: newItems.first?.title ?? "")
                    }
                } catch {
                    continue
                }
            }
            await MainActor.run {
                self.festivalData.value = newItems
            }
        }
    }

    func clearText() {
        festivalData.value = []
        scannedText.value = nil
        shouldNavigateToMakePlaylist.value = false
    }
}
