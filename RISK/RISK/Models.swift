//
//  Models.swift
//  RISK
//
//  Created by Barney Jason Evans on 12/30/25.
//

import Foundation

enum ScanType: String, CaseIterable, Identifiable, Codable {
    case whois
    case dns
    case fullOSINT

    var id: String { rawValue }

    var label: String {
        switch self {
        case .whois: return "WHOIS"
        case .dns: return "DNS / Network"
        case .fullOSINT: return "R.I.S.K OSINT"
        }
    }
}

struct ScanResult: Identifiable, Codable {
    let id: UUID
    let target: String
    let scanType: ScanType
    let title: String
    let command: String
    let output: String
    let timestamp: Date

    init(
        id: UUID = UUID(),
        target: String,
        scanType: ScanType,
        title: String,
        command: String,
        output: String,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.target = target
        self.scanType = scanType
        self.title = title
        self.command = command
        self.output = output
        self.timestamp = timestamp
    }
}

enum RISKCommandError: Error, LocalizedError {
    case emptyCommand
    case executionFailed(String)

    var errorDescription: String? {
        switch self {
        case .emptyCommand:
            return "Command is empty."
        case .executionFailed(let details):
            return "Command failed: \(details)"
        }
    }
}
