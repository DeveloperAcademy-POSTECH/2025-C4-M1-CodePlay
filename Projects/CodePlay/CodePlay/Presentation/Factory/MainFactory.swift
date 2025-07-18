//
//  MainFactory.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/11/25.
//

import SwiftUI

struct MainFactoryDependency: RootDependency {
    let mainFactory: any MainFactory
    let musicWrapper: AppleMusicConnectViewModelWrapper
}

protocol MainFactory {
    associatedtype SomeView: View
    func mainPosterView() -> SomeView
}

final class DefaultMainFactory: MainFactory {
    private let posterViewModelWrapper: PosterViewModelWrapper
    
    init(posterViewModelWrapper: PosterViewModelWrapper) {
        self.posterViewModelWrapper = posterViewModelWrapper
    }

    func mainPosterView() -> some View {
        return MainPosterView()
            .environmentObject(posterViewModelWrapper)
    }
}
