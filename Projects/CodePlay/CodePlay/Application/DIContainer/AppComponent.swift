//
//  AppComponent.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/15/25.
//

import SwiftUI
import SwiftData

private struct AppDependency: RootDependency {
    let mainFactory: any MainFactory
    let licenseFactory: any LicenseFactory
}

final class AppComponent {
    let modelContext: ModelContext
    private let appDIContainer = AppDIContainer()
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    private lazy var appFlowCoordinator: AppFlowCoordinator = .init(
        appDIContainer: appDIContainer, modelContext: modelContext
    )

    func makeRootView() -> some View {
        let mainFactory = appFlowCoordinator.mainFlowStart()
        let licenseFactory = appFlowCoordinator.licenseFlowStart()
        let diContainer = appDIContainer.mainSceneDIContainer(modelContext: modelContext)

        let musicWrapper =
            diContainer.appleMusicConnectViewModelWrapper()
        let posterWraper = diContainer.makePosterViewModelWrapper()

        LicenseManager.shared.configure(with: musicWrapper)
        print("🔍 License Status: \(LicenseManager.shared.isLicensed)")

        let rootView = MainView(mainFactory: mainFactory, licenseFactory: licenseFactory)
            .environmentObject(musicWrapper)
            .environmentObject(posterWraper)
        
        return rootView
    }
}
