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
    // 메인 씬(MainScene)의 DIContainer 생성
    func mainSceneDIContainer(modelContext: ModelContext) -> MainSceneDIContainer {
        return MainSceneDIContainer(modelContext: modelContext)
    }
}
