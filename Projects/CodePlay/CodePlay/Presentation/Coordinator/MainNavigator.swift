//
//  MainFlowCoordinatorDIContainer.swift
//  CodePlay
//
//  Created by 성현 on 7/14/25.
//

import Foundation

final class MainFlowCoordinatorDIContainer {
    // Repository
    private func makeTextRecognitionRepository() -> RecognizeTextRepository {
        DefaultRecognizeTextRepository()
    }

    // UseCase
    private func makeRecognizeTextUseCase() -> RecognizeTextUseCase {
        DefaultRecognizeTextUseCase(repository: makeTextRecognitionRepository())
    }

    // ViewModel
    func makeMainViewModel() -> any MainViewModel {
        DefaultMainViewModel(recognizeTextUseCase: makeRecognizeTextUseCase())
    }

    // Router
    func makeMainRouter() -> MainRouter {
        MainRouter()
    }

    // Factory
    func makeViewFactory() -> MainViewFactory {
        MainViewFactory(diContainer: self)
    }
}
