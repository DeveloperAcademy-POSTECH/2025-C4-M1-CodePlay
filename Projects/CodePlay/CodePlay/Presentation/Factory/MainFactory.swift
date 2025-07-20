//
//  MainFactory.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/11/25.
//

import SwiftUI

struct MainFactoryDependency: RootDependency {
    var licenseFactory: any LicenseFactory
    
    let mainFactory: any MainFactory
}

protocol MainFactory {
    associatedtype SomeView: View
    func mainPosterView() -> SomeView
}

final class DefaultMainFactory: MainFactory {
    private let posterViewModelWrapper: PosterViewModelWrapper
    private let diContainer: MainSceneDIContainer

    init(posterViewModelWrapper: PosterViewModelWrapper, diContainer: MainSceneDIContainer) {
        self.posterViewModelWrapper = posterViewModelWrapper
        self.diContainer = diContainer
    }

    func mainPosterView() -> some View {
        return MainPosterView(diContainer: diContainer)
            .environmentObject(posterViewModelWrapper)
    }
}

