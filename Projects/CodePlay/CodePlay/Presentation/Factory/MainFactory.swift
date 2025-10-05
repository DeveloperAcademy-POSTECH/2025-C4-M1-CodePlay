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
    let am: AppleMusicAPIServiceProtocol

    init(posterViewModelWrapper: PosterViewModelWrapper, musicViewModelWrapper: MusicViewModelWrapper, diContainer: MainSceneDIContainer, am:AppleMusicAPIServiceProtocol) {
        self.posterViewModelWrapper = posterViewModelWrapper
        self.musicViewModelWrapper = musicViewModelWrapper
        self.diContainer = diContainer
        self.am = am
    }

    public func mainPosterView() -> AnyView {
        return AnyView(MainPosterView(am:am)
            .environmentObject(posterViewModelWrapper))
    }
    
    public func mainMusicView() -> AnyView {
        return AnyView(AppleMusicConnectView()
            .environmentObject(musicViewModelWrapper))
    }
}

