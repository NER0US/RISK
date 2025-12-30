//
//  RISKAppState.swift
//  RISK
//
//  Created by NER0US on 12/30/25.
//

import SwiftUI

enum RISKTheme: String, CaseIterable, Identifiable {
    case hacker
    case minimal
    case starship
    case corporate

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .hacker: return "Hacker Terminal"
        case .minimal: return "Minimal"
        case .starship: return "Starship Core"
        case .corporate: return "Corporate Forensic"
        }
    }
}

final class RISKAppState: ObservableObject {
    @Published var theme: RISKTheme = .hacker
    @Published var lastExportURL: URL? = nil
}
