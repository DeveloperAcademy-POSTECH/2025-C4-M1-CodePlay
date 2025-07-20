//
//  MainLicenseDIContainer.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/20/25.
//

import SwiftUI
import SwiftData

final class MainLicenseDIContainer {
    // MARK: Factory
    func makeMainLicenseFactory() -> any LicenseFactory {
        let viewModelWrapper = appleMusicConnectViewModelWrapper()
        return DefaultLicenseFactory(musicWrapper: viewModelWrapper, diContainer: MainLicenseDIContainer())
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
    private func appleMusicConnectViewModel() -> any AppleMusicConnectViewModel {
        DefaultAppleMusicConnectViewModel(checkLicenseUseCase: makeCheckLicenseUseCase())
    }
    
    // MARK: ViewModelWrapper
    func appleMusicConnectViewModelWrapper() -> MusicViewModelWrapper {
        MusicViewModelWrapper(viewModel: appleMusicConnectViewModel())
    }
    
    func makeExportPlaylistViewModelWrapper(modelContext: ModelContext) -> ExportPlaylistViewModelWrapper {
        let useCase = makeExportPlaylistUseCase(modelContext: modelContext)
        let viewModel = DefaultExportPlaylistViewModel(useCase: useCase, modelContext: modelContext)
        return ExportPlaylistViewModelWrapper(viewModel: viewModel)
    }

}
