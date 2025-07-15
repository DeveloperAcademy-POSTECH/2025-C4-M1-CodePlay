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
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        let appDIContainer = AppDIContainer()
        let coordinator = AppFlowCoordinator(appDIContainer: appDIContainer)
        let mainFactory = coordinator.mainFlowStart()
        
        WindowGroup {
            MainView(mainFactory: DefaultMainFactory())
                .environmentObject(
                appDIContainer.mainSceneDIContainer().makeFetchFestivalViewModelWrapper()
            )
        }
        .modelContainer(sharedModelContainer)
    }
}
