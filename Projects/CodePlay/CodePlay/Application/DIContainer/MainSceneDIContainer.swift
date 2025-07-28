//
//  MainSceneDIContainer.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/12/25.
//

import SwiftUI
import SwiftData

final class MainSceneDIContainer {
    private let modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }
    
    // MARK: Factory
    func makeMainFactory() -> any MainFactory {
        return DefaultMainFactory(posterViewModelWrapper: makePosterViewModelWrapper(), musicViewModelWrapper: appleMusicConnectViewModelWrapper(), diContainer: self)
    }
    
    func makeMainLicenseFactory(modelContext: ModelContext) -> any LicenseFactory {
        let viewModelWrapper = appleMusicConnectViewModelWrapper()
        return DefaultLicenseFactory(
            musicWrapper: viewModelWrapper,
            diContainer: self
        )
    }
    
    
    // MARK: UseCases
    private func makeScanPosterUseCase() -> ScanPosterUseCase {
        return DefaultScanPosterUseCase(repository: makeScanPosterRepository())
    }
    
    private func makeCheckLicenseUseCase() -> CheckLicenseUseCase {
        return DefaultCheckLicenseUseCase(
            repository: makeCheckLicenseRepository()
        )
    }
    
    private func makeExportPlaylistUseCase(repository: ExportPlaylistRepository)
        -> ExportPlaylistUseCase {
        return DefaultExportPlaylistUseCase(repository: repository)
    }
    
    private func makeMusicPlayerUseCase() -> MusicPlayerUseCase {
        return DefaultMusicPlayerUseCase(repository: makeMusicPlayerRepository())
    }

    // MARK: Repository
    private func makeScanPosterRepository() -> ScanPosterRepository {
        DefaultScanPosterRepository()
    }
    
    private func makeCheckLicenseRepository() -> CheckLicenseRepository {
        DefaultCheckLicenseRepository()
    }

    private func makeExportPlaylistRepository() -> ExportPlaylistRepository {
        return DefaultExportPlaylistRepository(modelContext: modelContext)
    }
    
    private func makeMusicPlayerRepository() -> MusicPlayerRepository {
        return DefaultMusicPlayerRepository()
    }
    
    // MARK: ViewModel
    private func makePosterViewModel() -> any PosterViewModel {
        DefaultPosterViewModel(scanPosterUseCase: makeScanPosterUseCase())
    }
    
    private func appleMusicConnectViewModel() -> any AppleMusicConnectViewModel
    {
        DefaultAppleMusicConnectViewModel(
            checkLicenseUseCase: makeCheckLicenseUseCase()
        )
    }

    private func makeExportViewModel(exportRepository: ExportPlaylistRepository) -> any ExportPlaylistViewModel {
        let exportUseCase = makeExportPlaylistUseCase(repository: exportRepository)
        return DefaultExportPlaylistViewModel(useCase: exportUseCase, modelContext: modelContext)
    }
    
    // MARK: ViewModelWrapper
    func makePosterViewModelWrapper() -> PosterViewModelWrapper {
        return PosterViewModelWrapper(
            viewModel: makePosterViewModel(),
            playlist: Playlist(title: "")
        )
    }
    
    func appleMusicConnectViewModelWrapper() -> MusicViewModelWrapper {
           let exportRepository = makeExportPlaylistRepository()
           let exportViewModel = makeExportViewModel(exportRepository: exportRepository)
           let musicPlayerUseCase = makeMusicPlayerUseCase()

           return MusicViewModelWrapper(
               appleMusicConnectViewModel: appleMusicConnectViewModel(),
               exportViewModelWrapper: exportViewModel,
               musicPlayerUseCase: musicPlayerUseCase
           )
       }
}
