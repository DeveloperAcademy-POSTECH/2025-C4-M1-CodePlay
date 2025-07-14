//
//  AppDIcontainer.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/11/25.
//
import SwiftUI

final class AppDIContainer {
    func makeMainCoordinatorView() -> some View {
        let mainDI = MainSceneDIContainer()
        let router = mainDI.makeMainRouter()
        let factory = mainDI.makeViewFactory()
        return MainNavigator(router: router, factory: factory)
    }
}
