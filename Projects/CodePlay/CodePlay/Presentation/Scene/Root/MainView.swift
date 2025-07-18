//
//  MainView.swift
//  CodePlay
//
//  Created by 성현 on 7/15/25.
//

import SwiftUI

struct MainView: View {
    @StateObject private var wrapper: AppleMusicConnectViewModelWrapper
    private let mainFactory: any MainFactory

    init(mainFactory: any MainFactory, wrapper: AppleMusicConnectViewModelWrapper) {
        self.mainFactory = mainFactory
        _wrapper = StateObject(wrappedValue: wrapper)
    }

    var body: some View {
        Group {
            if wrapper.canPlayMusic {
                mainFactory.mainPosterView()
                    .wrapAnyView()
            } else {
                AppleMusicConnectView(viewModelWrapper: wrapper)
            }
        }
        .onAppear {
            wrapper.viewModel.updateMusicAuthorizationStatus()
        }
    }
}
