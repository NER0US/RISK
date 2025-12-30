//
//  ContentView.swift
//  RISK
//
//  Created by Barney Jason Evans on 12/30/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appState: RISKAppState
    @StateObject private var runner = CommandRunner()

    var body: some View {
        TabView {
            ScanPanelView(runner: runner)
                .tabItem {
                    Label("R.I.S.K Scan", systemImage: "shield.lefthalf.filled")
                }

            TerminalView(runner: runner)
                .tabItem {
                    Label("Terminal", systemImage: "terminal")
                }
        }
        .preferredColorScheme(.dark)
    }
}
