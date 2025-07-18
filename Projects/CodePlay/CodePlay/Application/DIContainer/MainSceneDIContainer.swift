//
//  MainSceneDIContainer.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/12/25.
//

import SwiftUI

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
    
    private func makeExportPlaylistUseCase() -> ExportPlaylistUseCase {
        return DefaultExportPlaylistUseCase(repository: makeExportPlaylistRepository())
    }
    
    // MARK: Repository
    private func makeCheckLicenseRepository() -> CheckLicenseRepository {
        DefaultCheckLicenseRepository()
    }
    
    private func makeScanPosterRepository() -> ScanPosterRepository {
        DefaultScanPosterRepository()
    }
    
    private func makeExportPlaylistRepository() -> ExportPlaylistRepository {
        DefaultExportPlaylistRepository()
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
    
    func makeExportPlaylistViewModelWrapper() -> ExportPlaylistViewModelWrapper {
        let useCase = makeExportPlaylistUseCase()
        let viewModel = DefaultExportPlaylistViewModel(useCase: useCase)
        return ExportPlaylistViewModelWrapper(viewModel: viewModel)
    }

}
