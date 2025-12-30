//
//  RISKApp.swift
//  RISK
//
//  Created by NER0US on 12/30/25.
//

import SwiftUI

@main
struct RISKApp: App {

    @StateObject private var appState = RISKAppState()
    @State private var introComplete: Bool = false

    var body: some Scene {

        // Intro / Splash Window (system-only, not user-creatable)
        WindowGroup(id: "intro") {
            if !introComplete {
                SplashView(introComplete: $introComplete)
            }
        }
        .windowStyle(.hiddenTitleBar)
        .windowResizability(.contentSize)
        .handlesExternalEvents(matching: []) // 🔒 hides from File → New

        // Main Application Window
        WindowGroup(id: "main") {
            if introComplete {
                ContentView()
                    .environmentObject(appState)
                    .frame(minWidth: 960, minHeight: 600)
            }
        }
        .windowStyle(.hiddenTitleBar)
    }
}
