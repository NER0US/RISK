//
//  RISKApp.swift
//  RISK
//
//  Created by Barney Jason Evans on 12/30/25.
//

import SwiftUI

@main
struct RISKApp: App {
    @StateObject private var appState = RISKAppState()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(appState)
                .frame(minWidth: 960, minHeight: 600)
        }
        .windowStyle(.hiddenTitleBar)
    }
}
