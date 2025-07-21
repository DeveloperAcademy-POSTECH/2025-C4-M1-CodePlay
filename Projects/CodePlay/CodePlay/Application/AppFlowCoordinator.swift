//
//  AppFlowCoordinator.swift
//  CodePlay
//
//  Created by 성현 on 7/15/25.
//

import SwiftUI
import SwiftData

final class AppFlowCoordinator {
    private let appDIContainer: AppDIContainer
    private let modelContext: ModelContext

    init(appDIContainer: AppDIContainer, modelContext: ModelContext) {
        self.appDIContainer = appDIContainer
        self.modelContext = modelContext
    }

    func mainFlowStart() -> any MainFactory {
        let mainSceneDIContainer = appDIContainer.mainSceneDIContainer(modelContext: modelContext)
        return mainSceneDIContainer.makeMainFactory()
    }
    
    func licenseFlowStart() -> any LicenseFactory {
        let licenseSceneDIContainer = appDIContainer.mainSceneDIContainer(modelContext: modelContext)
        return licenseSceneDIContainer.makeMainLicenseFactory(modelContext: modelContext)
    }
}
