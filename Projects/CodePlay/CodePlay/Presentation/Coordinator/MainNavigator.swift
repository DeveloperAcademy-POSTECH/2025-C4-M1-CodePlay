//
//  MainFlowCoordinatorDIContainer.swift
//  CodePlay
//
//  Created by 성현 on 7/14/25.
//
import SwiftUI

struct MainNavigator: View {
    @ObservedObject var router: MainRouter
    let factory: MainViewFactory

    var body: some View {
        NavigationStack(path: $router.path) {
            factory.makeMainView(router: router)
                .navigationDestination(for: MainRoute.self) { route in
                    switch route {
                    case .musicPermission:
                        MusicPermissionView()
//                        MusicPermissionView {
//                            router.replace(with: .main)
//                        }
                    case .main:
                        factory.makeMainView(router: router)
                    case .scanner:
                        factory.makeScannerView(router: router)
                    case .loading1(let rawText):
                        factory.makeFestivalLoadingView(router: router, rawText: rawText)
                    case .playlistResult:
                        PlaylistResultView()
                    case .loading2:
                        MusicSendingView()
                    }
                }
        }
    }
}
