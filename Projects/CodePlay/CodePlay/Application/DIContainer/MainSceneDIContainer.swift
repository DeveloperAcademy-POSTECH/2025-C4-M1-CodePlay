//
//  MainSceneDIContainer.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/12/25.
//

import SwiftData
import SwiftUI

final class MainSceneDIContainer {
    private let modelContext: ModelContext
    let am: AppleMusicAPIServiceProtocol
    
    // 1) 토큰 API 서비스
    private lazy var musicKitTokenService: MusicKitTokenAPIServiceProtocol = {
        let url = URL(string: Config.baseURL)!
        return MusicKitTokenAPIService(baseURL: url)
    }()

    // 2) 토큰 캐시 프로바이더(만료 전까지 재사용)
    private lazy var devTokenProvider = DevTokenProvider(api: musicKitTokenService)

    // 3) Apple Music REST 서비스(요청 직전 토큰 자동 보장)
    private lazy var appleMusicService: AppleMusicAPIServiceProtocol = {
        AppleMusicAPIService(tokenProvider: devTokenProvider)
    }()

    init(modelContext: ModelContext, am: AppleMusicAPIServiceProtocol) {
        self.modelContext = modelContext
        self.am = am
    }


    // MARK: Factory
    func makeMainFactory() -> any MainFactory {
        return DefaultMainFactory(
            posterViewModelWrapper: makePosterViewModelWrapper(),
            musicViewModelWrapper: appleMusicConnectViewModelWrapper(),
            diContainer: self,
            am:am
        )
    }

    func makeMainLicenseFactory(modelContext: ModelContext)
        -> any LicenseFactory
    {
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
    
    private func makeExportPlaylistUseCase() -> ExportPlaylistUseCase {
        return DefaultExportPlaylistUseCase(repository: makeExportPlaylistRepository())
    }

    private func makeMusicPlayerUseCase() -> MusicPlayerUseCase {
        return DefaultMusicPlayerUseCase(
            repository: makeMusicPlayerRepository()
        )
    }

    private func makeFestivalUseCase() -> FetchFestivalInfoUseCase {
        return DefaultFetchFestivalInfoUseCase(
            repository: makeFestivalRepository()
        )
    }

    // MARK: Repository
    private func makeScanPosterRepository() -> ScanPosterRepository {
        DefaultScanPosterRepository()
    }

    private func makeCheckLicenseRepository() -> CheckLicenseRepository {
        DefaultCheckLicenseRepository()
    }

    private func makeExportPlaylistRepository() -> ExportPlaylistRepository {
        DefaultExportPlaylistRepository(
            modelContext: modelContext,
            am: appleMusicService,
            storefront: "kr"
        )
    }
    
    private func makeMusicPlayerRepository() -> MusicPlayerRepository {
        return DefaultMusicPlayerRepository()
    }

    private func makeFestivalRepository() -> FestivalRepository {
        return DefaultFestivalRepository()
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

    private func makeFestivalCheckViewModel() -> any FestivalCheckViewModel {
        DefaultFestivalCheckViewModel(
            fetchFestivalInfoUseCase: makeFestivalUseCase()
        )
    }
    
    private func makeExportViewModel() -> any ExportPlaylistViewModel {
        DefaultExportPlaylistViewModel(useCase: makeExportPlaylistUseCase(), musicPlayerUseCase: makeMusicPlayerUseCase(), modelContext: modelContext)
    }

    // MARK: ViewModelWrapper
    func makePosterViewModelWrapper() -> PosterViewModelWrapper {
        return PosterViewModelWrapper(
            viewModel: makePosterViewModel()
        )
    }

    func appleMusicConnectViewModelWrapper() -> MusicViewModelWrapper {
        return MusicViewModelWrapper(
            appleMusicConnectViewModel: appleMusicConnectViewModel(),
            exportPlaylistViewModel: makeExportViewModel(),
            festivalCheckViewModel: makeFestivalCheckViewModel()
        )
    }
}

