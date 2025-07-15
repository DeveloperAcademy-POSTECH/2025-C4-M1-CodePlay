//
//  AppDIcontainer.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/11/25.
//

import Foundation

final class AppDIContainer {
    func mainSceneDIContainer() -> MainSceneDIContainer {
        return MainSceneDIContainer()
    }
    
    func appleMusicConnectViewModelWrapper() -> AppleMusicConnectViewModelWrapper {
            let viewModel = DefaultAppleMusicConnectViewModel()
            return AppleMusicConnectViewModelWrapper(viewModel: viewModel)
    }
}
