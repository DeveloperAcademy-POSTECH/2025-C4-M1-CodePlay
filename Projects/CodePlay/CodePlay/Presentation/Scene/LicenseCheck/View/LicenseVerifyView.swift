//
//  LicenseVerifyView.swift
//  CodePlay
//
//  Created by 성현 on 7/15/25.
//

import SwiftUI
import MusicKit
internal import Combine

struct LicenseVerifyView: View {
    @ObservedObject var viewModelWrapper: AppleMusicConnectViewModelWrapper
    @State private var showingSettings = false
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some View {
        AppleMusicConnectView(viewModelWrapper: viewModelWrapper)
            .sheet(isPresented: $showingSettings) {
                MusicSettingsView(viewModelWrapper: viewModelWrapper)
            }
            .onAppear {
                viewModelWrapper.viewModel.updateMusicAuthorizationStatus()
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    // 앱이 포그라운드로 복귀할 때 권한 상태 재확인
                    viewModelWrapper.viewModel.updateMusicAuthorizationStatus()
                }
            }
    }
}
