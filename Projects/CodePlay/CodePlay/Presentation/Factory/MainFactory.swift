//
//  MainFactory.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/11/25.
//

import SwiftUI

struct MainFactoryDependency: RootDependency {
    let mainFactory: any MainFactory
    let licenseFactory: any LicenseFactory
}

protocol MainFactory {
    func mainPosterView() -> AnyView
    func mainMusicView() -> AnyView
}

final class DefaultMainFactory: MainFactory {
    private let posterViewModelWrapper: PosterViewModelWrapper
    private let musicViewModelWrapper: MusicViewModelWrapper
    private let diContainer: MainSceneDIContainer

    init(posterViewModelWrapper: PosterViewModelWrapper, musicViewModelWrapper: MusicViewModelWrapper, diContainer: MainSceneDIContainer) {
        self.posterViewModelWrapper = posterViewModelWrapper
        self.musicViewModelWrapper = musicViewModelWrapper
        self.diContainer = diContainer
    }

    public func mainPosterView() -> AnyView {
        return AnyView(MainPosterView()
            .environmentObject(posterViewModelWrapper))
    }
    
    public func mainMusicView() -> AnyView {
        return AnyView(AppleMusicConnectView()
            .environmentObject(musicViewModelWrapper))
    }
}

