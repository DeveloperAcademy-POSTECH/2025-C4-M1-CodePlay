//
//  AppFlowCoordinator.swift
//  CodePlay
//
//  Created by 성현 on 7/15/25.
//

import SwiftUI

final class AppFlowCoordinator {
    private let appDIContainer: AppDIContainer

    init(
        appDIContainer: AppDIContainer
    ) {
        self.appDIContainer = appDIContainer
    }

    func mainFlowStart() -> any MainFactory {
        let mainSceneDIContainer = appDIContainer.mainSceneDIContainer()
        return mainSceneDIContainer.checkLicenseFactory()
    }
}
