//
//  MainSceneDIContainer.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/12/25.
//

import SwiftUI
import SwiftData

final class MainSceneDIContainer {
    // MARK: Factory
    func makeMainFactory() -> any MainFactory {
        let viewModelWrapper = makePosterViewModelWrapper()
        return DefaultMainFactory(posterViewModelWrapper: viewModelWrapper, diContainer: MainSceneDIContainer())
    }
    
    // MARK: UseCases
    private func makeCheckLicenseUseCase() -> CheckLicenseUseCase {
        return DefaultCheckLicenseUseCase(repository: makeCheckLicenseRepository())
    }
    
    private func makeScanPosterUseCase() -> ScanPosterUseCase {
        return DefaultScanPosterUseCase(repository: makeScanPosterRepository())
    }
    
    private func makeExportPlaylistUseCase(modelContext: ModelContext) -> ExportPlaylistUseCase {
        return DefaultExportPlaylistUseCase(repository: makeExportPlaylistRepository(modelContext: modelContext))
    }
    
    // MARK: Repository
    private func makeCheckLicenseRepository() -> CheckLicenseRepository {
        DefaultCheckLicenseRepository()
    }
    
    private func makeScanPosterRepository() -> ScanPosterRepository {
        DefaultScanPosterRepository()
    }
    
    private func makeExportPlaylistRepository(modelContext: ModelContext) -> ExportPlaylistRepository {
        DefaultExportPlaylistRepository(modelContext: modelContext)
    }
    
    // MARK: ViewModel
    private func makePosterViewModel() -> any PosterViewModel {
        DefaultPosterViewModel(scanPosterUseCase: makeScanPosterUseCase())
    }
    
    private func appleMusicConnectViewModel() -> any AppleMusicConnectViewModel {
        DefaultAppleMusicConnectViewModel(checkLicenseUseCase: makeCheckLicenseUseCase())
    }
    
    // MARK: ViewModelWrapper
    func makePosterViewModelWrapper() -> PosterViewModelWrapper {
        return PosterViewModelWrapper(
            viewModel: makePosterViewModel()
        )
    }
    
    func appleMusicConnectViewModelWrapper() -> AppleMusicConnectViewModelWrapper {
        AppleMusicConnectViewModelWrapper(viewModel: appleMusicConnectViewModel())
    }
    
    func makeExportPlaylistViewModelWrapper(modelContext: ModelContext) -> ExportPlaylistViewModelWrapper {
        let useCase = makeExportPlaylistUseCase(modelContext: modelContext)
        let viewModel = DefaultExportPlaylistViewModel(useCase: useCase, modelContext: modelContext)
        return ExportPlaylistViewModelWrapper(viewModel: viewModel)
    }

}
