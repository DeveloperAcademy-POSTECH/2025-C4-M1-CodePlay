//
//  MainViewModel.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/11/25.
//

//internal import Combine
//import Foundation
//import UIKit
//
//// MARK: MainViewModelInput
//protocol MainViewModelInput {
//    /// 페스티벌 이미지를 인식하는 함수
//    func recongizeFestivalLineup(from images: [UIImage])
//    /// 텍스트 초기화 함수
//    func clearText()
//}
//
//// MARK: MainViewModelOutput
//protocol MainViewModelOutput {
//    var rawText: Observable<RawText?> { get }
//}
//
//// MARK: MainViewModel
//protocol MainViewModel: MainViewModelInput, MainViewModelOutput,
//    ObservableObject {}
//
//// MARK: DefaultMainViewModel
//final class DefaultMainViewModel: MainViewModel {
//    var rawText: Observable<RawText?> = Observable(nil)
//    private let recognizeTextUseCase: RecognizeTextUseCase
//
//    init(recognizeTextUseCase: RecognizeTextUseCase) {
//        self.recognizeTextUseCase = recognizeTextUseCase
//    }
//
//    func recongizeFestivalLineup(from images: [UIImage]) {
//        Task {
//            let result = try await recognizeTextUseCase.execute(with: images)
//            await MainActor.run {
//                self.rawText.value = result
//            }
//        }
//    }
//
//    func clearText() {
//        rawText.value = nil
//    }
//}
