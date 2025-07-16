//
//  AppComponent.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/15/25.
//

import SwiftUI

final class AppComponent {
    private let appDIContainer = AppDIContainer()
    
    private lazy var appFlowCoordinator: AppFlowCoordinator = .init(appDIContainer: appDIContainer)
    
    func makePosterRootView() -> some View {
        let mainFactory = appFlowCoordinator.mainFlowStart()
        return rootComponent(mainFactory: mainFactory).makeView()
    }
    
    private func rootComponent(mainFactory: any MainFactory) -> RootComponent {
        RootComponent(dependency: MainFactoryDependency(mainFactory: mainFactory))
    }
}
