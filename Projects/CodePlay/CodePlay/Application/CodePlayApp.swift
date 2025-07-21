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
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var sharedModelContainer: ModelContainer = {
            let schema = Schema([
                Playlist.self,           // ✅ 포함되어야 함
                PlaylistEntry.self,      // ✅ 포함되어야 함
            ])
            let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

            do {
                return try ModelContainer(for: schema, configurations: [config])
            } catch {
                fatalError("❌ ModelContainer 생성 실패: \(error)")
            }
        }()

    var body: some Scene {
        WindowGroup {
            let modelContext = sharedModelContainer.mainContext
            AppComponent(modelContext: modelContext)
                .makeRootView()
                .environment(\.modelContext, modelContext)
        }
        .modelContainer(sharedModelContainer)
    }
}
