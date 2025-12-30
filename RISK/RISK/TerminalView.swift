//
//  TerminalView.swift
//  RISK
//
//  Created by NER0US on 12/30/25.
//

import SwiftUI

struct TerminalView: View {
    @ObservedObject var runner: CommandRunner
    @State private var commandInput: String = ""

    var body: some View {
        VStack(spacing: 8) {

            HStack {
                Text("R.I.S.K Shell")
                    .font(.system(size: 14, weight: .semibold, design: .monospaced))
                Spacer()
                if runner.isRunning {
                    ProgressView()
                        .scaleEffect(0.7)
                }
            }
            .padding(.horizontal, 4)

            ScrollView {
                Text(
                    runner.lastOutput.isEmpty
                        ? "Command output will appear here..."
                        : runner.lastOutput
                )
                .font(.system(.body, design: .monospaced))
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .padding(8)
                .background(Color.black.opacity(0.9))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.green.opacity(0.6), lineWidth: 1)
                )
                .cornerRadius(8)
                .foregroundColor(.green.opacity(0.9))
            }

            HStack(spacing: 8) {
                Text("> ")
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.green.opacity(0.9))

                TextField("Enter shell command…", text: $commandInput)
                    .textFieldStyle(.plain)
                    .font(.system(.body, design: .monospaced))
                    .foregroundColor(.green.opacity(0.95))
                    .disabled(runner.isRunning)

                Button(
                    action: {
                        let cmd = commandInput
                        commandInput = ""
                        runner.run(cmd, completion: nil)
                    },
                    label: {
                        Text("Run")
                    }
                )
                .keyboardShortcut(.return, modifiers: [])
                .disabled(
                    runner.isRunning ||
                    commandInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                )
            }
            .padding(8)
            .background(Color.black.opacity(0.9))
            .cornerRadius(8)
        }
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(
                    colors: [
                        Color.black,
                        Color.black.opacity(0.95)
                    ]
                ),
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }
}
