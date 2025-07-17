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

    var body: some Scene {
        WindowGroup {
            AppComponent()
                .makePosterRootView()
        }
    }
}
