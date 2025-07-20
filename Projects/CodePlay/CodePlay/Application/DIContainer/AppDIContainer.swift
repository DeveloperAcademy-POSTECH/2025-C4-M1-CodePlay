//
//  AppDIcontainer.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/11/25.
//

import Foundation
import SwiftData

// 앱 전역에서 사용할 의존성 주입 컨테이너
final class AppDIContainer {
    
    // 메인 씬(MainScene)의 DIContainer 생성
    func mainSceneDIContainer() -> MainSceneDIContainer {
        return MainSceneDIContainer()
    }
    
    func mainLicenseSceneDIContainer() -> MainLicenseDIContainer {
        return MainLicenseDIContainer()
        
    }
    
//    // Apple Music 라이선스 확인 UseCase 생성 (내부 전용)
//    private func makeCheckLicenseUseCase() -> CheckLicenseUseCase {
//        let repository = DefaultCheckLicenseRepository()
//        return DefaultCheckLicenseUseCase(repository: repository)
//    }
//    
//    // AppleMusicConnect 화면에서 사용할 ViewModelWrapper 제공
//    func appleMusicConnectViewModelWrapper() -> MusicViewModelWrapper {
//        let viewModel = DefaultAppleMusicConnectViewModel(checkLicenseUseCase: makeCheckLicenseUseCase())
//        return MusicViewModelWrapper(viewModel: viewModel)
//    }
//    
//    // ExportPlaylist 흐름에서 사용할 ViewModelWrapper 생성 (SwiftData context 주입 필요)
//    func makeExportPlaylistViewModelWrapper(modelContext: ModelContext) -> ExportPlaylistViewModelWrapper {
//        let repository = DefaultExportPlaylistRepository(modelContext: modelContext)
//        let useCase = DefaultExportPlaylistUseCase(repository: repository)
//        let viewModel = DefaultExportPlaylistViewModel(
//            useCase: useCase,
//            modelContext: modelContext
//        )
//        return ExportPlaylistViewModelWrapper(viewModel: viewModel)
//    }
}
