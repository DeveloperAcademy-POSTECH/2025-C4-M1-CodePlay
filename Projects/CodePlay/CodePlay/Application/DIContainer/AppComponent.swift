//
//  AppComponent.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/15/25.
//

import SwiftUI

private struct AppDependency: RootDependency {
    let mainFactory: any MainFactory
    let licenseFactory: any LicenseFactory
}

final class AppComponent {
    private let appDIContainer = AppDIContainer()

    private lazy var appFlowCoordinator: AppFlowCoordinator = .init(
        appDIContainer: appDIContainer
    )

    func makeRootView() -> some View {
        let mainFactory = appFlowCoordinator.mainFlowStart()
        let licenseDIContainer = appDIContainer.mainLicenseSceneDIContainer()

        let musicWrapper =
            licenseDIContainer.appleMusicConnectViewModelWrapper()
        let licenseFactory = DefaultLicenseFactory(
            musicWrapper: musicWrapper,
            diContainer: licenseDIContainer
        )
        LicenseManager.shared.configure(with: musicWrapper)

        let dependency = AppDependency(
            mainFactory: mainFactory,
            licenseFactory: licenseFactory
        )

        return RootComponent(dependency: dependency).makeView()
    }
}
