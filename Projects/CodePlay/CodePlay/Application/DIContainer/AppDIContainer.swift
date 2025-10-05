//
//  AppDIcontainer.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/11/25.
//

import Foundation
import SwiftData

// 앱 전역에서 사용할 의존성 주입 컨테이너
final class AppDIContainer {
    let am: AppleMusicAPIServiceProtocol

    init(am: AppleMusicAPIServiceProtocol? = nil) {
        if let am {
            self.am = am
        } else {
            // Construct dependencies locally to avoid using self before initialization
            let url = URL(string: Config.baseURL)!
            let musicKitTokenService: MusicKitTokenAPIServiceProtocol = MusicKitTokenAPIService(baseURL: url)
            let devTokenProvider = DevTokenProvider(api: musicKitTokenService)
            self.am = AppleMusicAPIService(tokenProvider: devTokenProvider)
        }
    }

    func mainSceneDIContainer(modelContext: ModelContext) -> MainSceneDIContainer {
        return MainSceneDIContainer(modelContext: modelContext, am: am)
    }
}
