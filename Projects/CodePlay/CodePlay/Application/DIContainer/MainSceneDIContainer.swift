//
//  MainSceneDIContainer.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/12/25.
//

import SwiftUI

final class MainSceneDIContainer {
    // MARK: Factory
    func checkLicenseFactory() -> any MainFactory {
        return DefaultMainFactory()
    }
    
    // MARK: UseCases
    private func makeCheckLicenseUseCase() -> CheckLicenseUseCase {
        return DefaultCheckLicenseUseCase()
    }
    
    private func makeFetchFestivalUseCase() -> FetchFestivalUseCase {
        return DefaultFetchFestivalUseCase()
    }
    
    private func makeScanPosterUseCase() -> ScanPosterUseCase {
        return DefaultScanPosterUseCase(repository: makeScanPosterRepository())
    }
    
    private func makeAnalyzingWordUseCase() -> AnalyzingWordUseCase {
        return DefaultAnalyzingWordUseCase()
    }
    
    private func makeSearchSongUseCase() -> SearchSongUseCase {
        return DefaultSearchSongUseCase()
    }
    
    private func makeFetchPlaylistUseCase() -> FetchPlaylistUseCase {
        return DefaultFetchPlaylistUseCase()
    }
    
    private func makeSendPlaylistUseCase() -> SendPlaylistUseCase {
        return DefaultSendPlaylistUseCase()
    }
    
    // MARK: Repository
    private func makeCheckLicenseRepository() -> CheckLicenseRepository {
        DefaultCheckLicenseRepository()
    }
    
    private func makeFetchFestivalRepository() -> FetchFestivalRepository {
        DefaultFetchFestivalRepository()
    }
    
    private func makeScanPosterRepository() -> ScanPosterRepository {
        DefaultScanPosterRepository()
    }
    
    private func makeAnalyzingWordRepository() -> AnalyzingWordRepository {
        DefaultAnalyzingWordRepository()
    }
    
    private func makeSearchSongRepository() -> SearchSongRepository {
        DefaultSearchSongRepository()
    }
    
    private func makeFetchPlaylistRepository() -> FetchPlaylistRepository {
        DefaultFetchPlaylistRepository()
    }
    
    private func makeSendPlaylistRepository() -> SendPlaylistRepository {
        DefaultSendPlaylistRepository()
    }
    
    // MARK: ViewModel
    private func fetchFestivalViewModel() -> any PosterViewModel {
        DefaultPosterViewModel(scanPosterUseCase: makeScanPosterUseCase())
    }
    
    // MARK: ViewModelWrapper
    func makeFetchFestivalViewModelWrapper() -> FetchFestivalViewModelWrapper {
        let useCase = makeScanPosterUseCase()
        let fetchVM = DefaultPosterViewModel(scanPosterUseCase: useCase)
        let scanVM = ScanPosterViewModel(scanPosterUseCase: useCase)

        return FetchFestivalViewModelWrapper(
            viewModel: fetchVM,
            scanPosterViewModel: scanVM
        )
    }

}
