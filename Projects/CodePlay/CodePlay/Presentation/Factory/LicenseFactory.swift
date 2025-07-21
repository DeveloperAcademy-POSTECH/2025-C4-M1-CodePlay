//
//  LicenseFactory.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/20/25.
//

import SwiftUI

struct LicenseFactoryDependency: RootDependency {
    var mainFactory: any MainFactory
    let licenseFactory: any LicenseFactory
}

protocol LicenseFactory {
    associatedtype SomeView: View
    func mainLicenseView() -> SomeView
}

final class DefaultLicenseFactory: LicenseFactory {
    private let musicWrapper: MusicViewModelWrapper
    private let diContainer: MainSceneDIContainer
    
    init(musicWrapper: MusicViewModelWrapper, diContainer: MainSceneDIContainer) {
        self.musicWrapper = musicWrapper
        self.diContainer = diContainer
    }
    
    func mainLicenseView() -> some View {
        return AppleMusicConnectView()
            .environmentObject(musicWrapper)
    }
    
}

