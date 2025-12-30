//
//  ScanPanelView.swift
//  RISK
//
//  Created by Barney Jason Evans on 12/30/25.
//

import SwiftUI

struct ScanPanelView: View {
    @EnvironmentObject var appState: RISKAppState
    @ObservedObject var runner: CommandRunner

    @State private var target: String = ""
    @State private var selectedScanType: ScanType = .whois
    @State private var results: [ScanResult] = []
    @State private var activeResultID: UUID? = nil
    @State private var statusMessage: String = ""
    @State private var isExporting: Bool = false
    @State private var exportAlertMessage: String? = nil

    var body: some View {
        VStack(spacing: 0) {
            headerBar
                .padding()
                .background(Color.black.opacity(0.95))

            Divider()
                .background(Color.green.opacity(0.6))

            HStack(spacing: 0) {
                sidebar
                    .frame(width: 260)
                    .background(Color.black.opacity(0.98))

                Divider()
                    .background(Color.green.opacity(0.4))

                mainOutput
            }
        }
        .alert(item: Binding(
            get: { exportAlertMessage.map { AlertWrapper(message: $0) } },
            set: { exportAlertMessage = $0?.message }
        )) { wrapper in
            Alert(
                title: Text("Export Complete"),
                message: Text(wrapper.message),
                dismissButton: .default(Text("OK"))
            )
        }
    }

    // MARK: - Header

    private var headerBar: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 4) {
                Text("R.I.S.K")
                    .font(.system(size: 22, weight: .bold, design: .monospaced))
                    .foregroundColor(.green.opacity(0.95))

                Text("Real Internet Security Knowledge")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.green.opacity(0.7))
            }

            Spacer()

            Picker("Theme", selection: $appState.theme) {
                ForEach(RISKTheme.allCases) { theme in
                    Text(theme.displayName).tag(theme)
                }
            }
            .pickerStyle(.menu)
            .frame(width: 200)
            .foregroundColor(.green.opacity(0.9))

            if !statusMessage.isEmpty {
                Text(statusMessage)
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.green.opacity(0.7))
            }
        }
    }

    // MARK: - Sidebar

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Target")
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundColor(.green.opacity(0.8))

            TextField("domain.com, IP, URL…", text: $target)
                .textFieldStyle(.roundedBorder)
                .font(.system(.body, design: .monospaced))
                .disableAutocorrection(true)

            Text("Scan Type")
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundColor(.green.opacity(0.8))
                .padding(.top, 4)

            Picker("Scan Type", selection: $selectedScanType) {
                ForEach(ScanType.allCases) { type in
                    Text(type.label).tag(type)
                }
            }
            .pickerStyle(.segmented)

            VStack(spacing: 6) {
                Button(action: runSelectedScan) {
                    HStack {
                        if runner.isRunning { ProgressView().scaleEffect(0.7) }
                        Text(runner.isRunning ? "Running…" : "Run Scan")
                            .font(.system(size: 13, weight: .semibold, design: .monospaced))
                    }
                    .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .tint(.green.opacity(0.9))
                .disabled(runner.isRunning || target.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                Button(action: runFullChain) {
                    Text("Run Full R.I.S.K Chain")
                        .font(.system(size: 12, design: .monospaced))
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.green.opacity(0.7))
                .disabled(runner.isRunning || target.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }

            Divider()
                .background(Color.green.opacity(0.5))
                .padding(.vertical, 8)

            Text("Results")
                .font(.system(size: 12, weight: .semibold, design: .monospaced))
                .foregroundColor(.green.opacity(0.8))

            List(selection: $activeResultID) {
                ForEach(results) { result in
                    VStack(alignment: .leading, spacing: 2) {
                        Text(result.title)
                            .font(.system(size: 13, weight: .semibold, design: .monospaced))
                        Text(result.timestamp.formatted(date: .abbreviated, time: .shortened))
                            .font(.system(size: 11, design: .monospaced))
                            .foregroundColor(.green.opacity(0.7))
                    }
                    .tag(result.id as UUID?)
                }
            }
            .listStyle(.plain)

            Spacer()

            Button(action: exportAll) {
                Label("Export TXT / CSV / JSON", systemImage: "square.and.arrow.down")
                    .font(.system(size: 11, weight: .semibold, design: .monospaced))
            }
            .buttonStyle(.bordered)
            .tint(.green.opacity(0.8))
            .disabled(results.isEmpty || isExporting)
        }
        .padding()
    }

    // MARK: - Main Output

    private var mainOutput: some View {
        VStack {
            if let active = results.first(where: { $0.id == activeResultID }) ?? results.last {
                ScrollView {
                    Text(active.output.isEmpty ? "No output." : active.output)
                        .font(.system(.body, design: .monospaced))
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .padding()
                }
                .background(Color.black.opacity(0.98))
            } else {
                Text("No scans yet.")
                    .font(.system(size: 14, design: .monospaced))
                    .foregroundColor(.green.opacity(0.7))
            }
        }
        .background(Color.black.opacity(0.98))
    }

    // MARK: - Actions

    private func runSelectedScan() {
        let trimmed = target.trimmingCharacters(in: .whitespacesAndNewlines)
        let (title, command) = commandFor(scanType: selectedScanType, target: trimmed)
        statusMessage = "Running \(selectedScanType.label)…"

        runner.run(command) { result in
            let output: String
            switch result {
            case .success(let out): output = out
            case .failure(let err): output = err.localizedDescription
            }

            let record = ScanResult(
                target: trimmed,
                scanType: selectedScanType,
                title: title,
                command: command,
                output: output
            )

            results.append(record)
            activeResultID = record.id
            statusMessage = ""
        }
    }

    private func runFullChain() {
        let trimmed = target.trimmingCharacters(in: .whitespacesAndNewlines)
        let steps: [(ScanType, String, String)] = [
            (.whois, "WHOIS", "deep-whois \(trimmed)"),
            (.dns, "DNS", "dig +short \(trimmed)"),
            (.fullOSINT, "Nmap", "nmap -Pn -F \(trimmed)")
        ]

        runChain(steps: steps, index: 0, target: trimmed)
    }

    private func runChain(
        steps: [(ScanType, String, String)],
        index: Int,
        target: String
    ) {
        guard index < steps.count else { return }

        let step = steps[index]
        runner.run(step.2) { result in
            let output: String
            switch result {
            case .success(let out): output = out
            case .failure(let err): output = err.localizedDescription
            }

            results.append(
                ScanResult(
                    target: target,
                    scanType: step.0,
                    title: step.1,
                    command: step.2,
                    output: output
                )
            )

            activeResultID = results.last?.id
            runChain(steps: steps, index: index + 1, target: target)
        }
    }

    private func commandFor(
        scanType: ScanType,
        target: String
    ) -> (String, String) {
        switch scanType {
        case .whois:
            return ("WHOIS", "deep-whois \(target)")
        case .dns:
            return ("DNS / dig", "dig +short \(target)")
        case .fullOSINT:
            return ("R.I.S.K OSINT", "echo 'Use full chain'")
        }
    }

    private func exportAll() {
        guard let firstTarget = results.first?.target else { return }
        isExporting = true

        DispatchQueue.global(qos: .userInitiated).async {
            let urls = try? ExportManager.exportAll(for: firstTarget, results: results)
            DispatchQueue.main.async {
                isExporting = false
                exportAlertMessage = urls?.map { $0.path }.joined(separator: "\n")
            }
        }
    }

    private struct AlertWrapper: Identifiable {
        let id = UUID()
        let message: String
    }
}
