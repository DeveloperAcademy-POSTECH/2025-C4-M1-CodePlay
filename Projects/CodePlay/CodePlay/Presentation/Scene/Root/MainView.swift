//
//  MainView.swift
//  CodePlay
//
//  Created by 성현, Yan on 7/15/25.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject var wrapper: MusicViewModelWrapper
    @Environment(\.scenePhase) var scenePhase
    private let mainFactory: any MainFactory
    private let licenseFactory: any LicenseFactory
    
    init(mainFactory: any MainFactory, licenseFactory: any LicenseFactory) {
        self.mainFactory = mainFactory
        self.licenseFactory = licenseFactory
    }

    var body: some View {
        Group {
            if wrapper.canPlayMusic {
                mainFactory.mainPosterView()
                    .wrapAnyView()
            } else {
                licenseFactory.mainLicenseView()
                    .wrapAnyView()
            }
        }
        .onAppear {
            wrapper.appleMusicConnectViewModel.updateMusicAuthorizationStatus()
        }
        .onChange(of: scenePhase) { newPhase in
            if newPhase == .active {
                wrapper.appleMusicConnectViewModel.updateMusicAuthorizationStatus()
            }
            
        }
    }
}
