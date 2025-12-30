//
//  CommandRunner.swift
//  RISK
//
//  Created by NER0US on 12/30/25.
//

import Foundation
import Combine

final class CommandRunner: ObservableObject {
    @Published var isRunning: Bool = false
    @Published var lastOutput: String = ""
    @Published var lastError: String? = nil

    func run(
        _ command: String,
        workingDirectory: URL? = nil,
        completion: ((Result<String, RISKCommandError>) -> Void)? = nil
    ) {
        let trimmed = command.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            let err = RISKCommandError.emptyCommand
            lastError = err.localizedDescription
            completion?(.failure(err))
            return
        }

        isRunning = true
        lastError = nil

        DispatchQueue.global(qos: .userInitiated).async {
            let process = Process()
            process.executableURL = URL(fileURLWithPath: "/bin/zsh")
            process.arguments = ["-lc", trimmed]

            if let wd = workingDirectory {
                process.currentDirectoryURL = wd
            }

            let pipe = Pipe()
            process.standardOutput = pipe
            process.standardError = pipe

            do {
                try process.run()
            } catch {
                DispatchQueue.main.async {
                    self.isRunning = false
                    let err = RISKCommandError.executionFailed(error.localizedDescription)
                    self.lastError = err.localizedDescription
                    completion?(.failure(err))
                }
                return
            }

            let data = pipe.fileHandleForReading.readDataToEndOfFile()
            let output = String(data: data, encoding: .utf8) ?? ""

            process.waitUntilExit()

            DispatchQueue.main.async {
                self.isRunning = false
                self.lastOutput = output

                if process.terminationStatus == 0 {
                    completion?(.success(output))
                } else {
                    let errMsg = output.isEmpty ? "Unknown error." : output
                    let err = RISKCommandError.executionFailed(errMsg)
                    self.lastError = err.localizedDescription
                    completion?(.failure(err))
                }
            }
        }
    }
}
