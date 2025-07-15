//
//  CodePlayApp.swift
//  CodePlay
//
//  Created by 아우신얀 on 7/8/25.
//

import SwiftUI
import SwiftData

@main
struct CodePlayApp: App {
    private let diContainer = MainSceneDIContainer()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([Item.self])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainView(
                mainFactory: diContainer.checkLicenseFactory(),
                wrapper: diContainer.appleMusicConnectViewModelWrapper()
            )
        }
        .modelContainer(sharedModelContainer)
    }
}

