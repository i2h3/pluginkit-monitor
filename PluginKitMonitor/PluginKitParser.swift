import Foundation

/// Parses the verbose output of the `pluginkit` command-line tool.
///
/// This type provides two entry points:
/// - ``runPluginKit()`` spawns a new `pluginkit -mvvvv` process, captures its
///   standard output, and returns the parsed result.
/// - ``parse(_:)`` accepts a raw output string and returns an array of
///   ``PluginInfo`` values, useful for unit-testing without a live system.
nonisolated
enum PluginKitParser {

    /// Executes `/usr/bin/pluginkit -mvvvv` and returns parsed plug-in entries.
    ///
    /// Returns an empty array when the process cannot be launched or produces
    /// no UTF-8 output.
    static func runPluginKit() -> [PluginInfo] {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/pluginkit")
        process.arguments = ["-mvvvv"]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = FileHandle.nullDevice

        do {
            try process.run()
        } catch {
            return []
        }

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        process.waitUntilExit()

        guard let output = String(data: data, encoding: .utf8) else { return [] }
        return parse(output)
    }

    /// Parses the raw text output of `pluginkit -mvvvv` into an array of ``PluginInfo``.
    ///
    /// Each plug-in block starts with an optional election-state prefix (`+`, `-`,
    /// `!`, `=`, `?`) followed by the bundle identifier and version in parentheses,
    /// then indented key-value metadata lines separated by a blank line.
    ///
    /// - Parameter output: The complete standard-output string from `pluginkit`.
    /// - Returns: An array of ``PluginInfo`` values in the order they appeared.
    static func parse(_ output: String) -> [PluginInfo] {
        var plugins: [PluginInfo] = []
        let lines = output.components(separatedBy: "\n")
        var index = 0

        while index < lines.count {
            let line = lines[index]

            // Match header line: optional election prefix, whitespace, bundleID(version)
            // e.g. "     com.apple.tips.Widget(26.3)"
            // e.g. "+    com.apple.dt.Instruments.InstrumentsShareExtension(26.3)"
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard let match = trimmed.wholeMatch(of: /([+\-!=?])?\s*(.+?)\((.+?)\)/) else {
                index += 1
                continue
            }

            let prefixChar = match.1.map(String.init) ?? ""
            let electionState = PluginElectionState(rawValue: prefixChar) ?? .none
            let bundleIdentifier = String(match.2)
            let version = String(match.3)

            // Collect key-value pairs until we hit an empty line or another header.
            var fields: [String: String] = [:]
            index += 1

            while index < lines.count {
                let kvLine = lines[index]
                // Empty line signals end of this entry.
                if kvLine.trimmingCharacters(in: .whitespaces).isEmpty {
                    index += 1
                    break
                }
                // Parse "Key = Value" patterns.
                if let kvMatch = kvLine.wholeMatch(of: /\s+(.+?)\s+=\s+(.+)/) {
                    fields[String(kvMatch.1)] = String(kvMatch.2)
                }
                index += 1
            }

            let plugin = PluginInfo(
                electionState: electionState,
                bundleIdentifier: bundleIdentifier,
                version: version,
                path: fields["Path"] ?? "",
                uuid: fields["UUID"] ?? "",
                timestamp: fields["Timestamp"] ?? "",
                sdk: fields["SDK"] ?? "",
                displayName: fields["Display Name"] ?? "",
                shortName: fields["Short Name"] ?? "",
                parentName: fields["Parent Name"]
            )
            plugins.append(plugin)
        }

        return plugins
    }
}
