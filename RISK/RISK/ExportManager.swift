//
//  ExportManager.swift
//  RISK
//
//  Created by Barney Jason Evans on 12/30/25.
//

import Foundation

struct ExportManager {
    static let baseFolderName = "RISK-Exports"

    static func exportAll(
        for target: String,
        results: [ScanResult]
    ) throws -> [URL] {
        guard !results.isEmpty else { return [] }

        let fm = FileManager.default
        let home = fm.homeDirectoryForCurrentUser
        let base = home.appendingPathComponent(baseFolderName, isDirectory: true)
        let targetFolder = base.appendingPathComponent(
            safeFileName(target),
            isDirectory: true
        )

        if !fm.fileExists(atPath: base.path) {
            try fm.createDirectory(at: base, withIntermediateDirectories: true)
        }

        if !fm.fileExists(atPath: targetFolder.path) {
            try fm.createDirectory(at: targetFolder, withIntermediateDirectories: true)
        }

        let timestamp = isoStamp()

        let txtURL = targetFolder.appendingPathComponent("risk_\(timestamp).txt")
        let csvURL = targetFolder.appendingPathComponent("risk_\(timestamp).csv")
        let jsonURL = targetFolder.appendingPathComponent("risk_\(timestamp).json")

        // TXT
        let txtBody = makeTextExport(target: target, results: results)
        try txtBody.write(to: txtURL, atomically: true, encoding: .utf8)

        // CSV
        let csvBody = makeCSVExport(results: results)
        try csvBody.write(to: csvURL, atomically: true, encoding: .utf8)

        // JSON
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .withoutEscapingSlashes]
        let jsonData = try encoder.encode(results)
        try jsonData.write(to: jsonURL)

        return [txtURL, csvURL, jsonURL]
    }

    // MARK: - Helpers

    private static func makeTextExport(
        target: String,
        results: [ScanResult]
    ) -> String {
        var out = ""
        out += "R.I.S.K – Real Internet Security Knowledge\n"
        out += "Target: \(target)\n"
        out += "Generated: \(Date())\n"
        out += String(repeating: "=", count: 60) + "\n\n"

        for result in results {
            out += "[\(result.scanType.label)] \(result.title)\n"
            out += "Command: \(result.command)\n"
            out += "Timestamp: \(result.timestamp)\n"
            out += String(repeating: "-", count: 40) + "\n"
            out += result.output
            if !result.output.hasSuffix("\n") { out += "\n" }
            out += String(repeating: "=", count: 60) + "\n\n"
        }

        return out
    }

    private static func makeCSVExport(results: [ScanResult]) -> String {
        var out = "id,target,scan_type,title,timestamp,command,output\n"

        for r in results {
            let line = [
                r.id.uuidString,
                csvEscape(r.target),
                csvEscape(r.scanType.label),
                csvEscape(r.title),
                csvEscape(isoStamp(from: r.timestamp)),
                csvEscape(r.command),
                csvEscape(r.output.replacingOccurrences(of: "\n", with: "\\n"))
            ].joined(separator: ",")

            out += line + "\n"
        }

        return out
    }

    private static func csvEscape(_ value: String) -> String {
        var v = value
        v = v.replacingOccurrences(of: "\"", with: "\"\"")
        return "\"\(v)\""
    }

    private static func safeFileName(_ raw: String) -> String {
        let invalid = CharacterSet(charactersIn: "/:\\?%*|\"<>")
        let cleaned = raw.components(separatedBy: invalid).joined(separator: "_")
        return cleaned.isEmpty ? "target" : cleaned
    }

    private static func isoStamp(from date: Date = Date()) -> String {
        let df = DateFormatter()
        df.dateFormat = "yyyyMMdd_HHmmss"
        df.locale = Locale(identifier: "en_US_POSIX")
        return df.string(from: date)
    }
}
