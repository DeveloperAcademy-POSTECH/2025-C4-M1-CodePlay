//
//  AppDIcontainer.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/11/25.
//

import Foundation
import SwiftData

final class AppDIContainer {
    func mainSceneDIContainer() -> MainSceneDIContainer {
        return MainSceneDIContainer()
    }
    
    private func makeCheckLicenseUseCase() -> CheckLicenseUseCase {
        let repository = DefaultCheckLicenseRepository()
        return DefaultCheckLicenseUseCase(repository: repository)
    }
    
    func appleMusicConnectViewModelWrapper() -> AppleMusicConnectViewModelWrapper {
        let viewModel = DefaultAppleMusicConnectViewModel(checkLicenseUseCase: makeCheckLicenseUseCase())
        return AppleMusicConnectViewModelWrapper(viewModel: viewModel)
    }
    
    func makeExportPlaylistViewModelWrapper(modelContext: ModelContext) -> ExportPlaylistViewModelWrapper {
        let repository = DefaultExportPlaylistRepository(modelContext: modelContext)
        let useCase = DefaultExportPlaylistUseCase(repository: repository)
        let viewModel = DefaultExportPlaylistViewModel(useCase: useCase)
        return ExportPlaylistViewModelWrapper(viewModel: viewModel)
    }
}
