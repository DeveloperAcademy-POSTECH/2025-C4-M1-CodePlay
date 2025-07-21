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
    associatedtype PosterViewType: View
    associatedtype MusicViewType: View
    
    func mainPosterView() -> PosterViewType
    func mainMusicView() -> MusicViewType
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

    public func mainPosterView() -> some View {
        return MainPosterView()
            .environmentObject(posterViewModelWrapper)
    }
    
    public func mainMusicView() -> some View {
        return AppleMusicConnectView()
            .environmentObject(musicViewModelWrapper)
    }
}

