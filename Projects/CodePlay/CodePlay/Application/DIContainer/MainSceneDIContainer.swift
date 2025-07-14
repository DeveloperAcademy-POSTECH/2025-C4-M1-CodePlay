//
//  MainSceneDIContainer.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/12/25.
//

import SwiftUI

final class MainSceneDIContainer {
    // MARK: UseCases
    private func makeRecognizeTextUseCase() -> RecognizeTextUseCase {
        DefaultRecognizeTextUseCase(repository: makeTextRecognitionRepository())
    }

    // MARK: Repository
    private func makeTextRecognitionRepository()
        -> DefaultRecognizeTextRepository {
        DefaultRecognizeTextRepository()
    }

    // MARK: ViewModel
    private func makeMainViewModel() -> any MainViewModel {
        DefaultMainViewModel(recognizeTextUseCase: makeRecognizeTextUseCase())
    }

    // MARK: ViewModelWrapper
    func makeMainViewModelWrapper() -> MainViewModelWrapper {
        MainViewModelWrapper(viewModel: makeMainViewModel())
    }

    // MARK: Router
    func makeMainRouter() -> MainRouter {
        MainRouter()
    }

    // MARK: Factory
    func makeViewFactory() -> MainViewFactory {
        MainViewFactory(diContainer: self)
    }
}
