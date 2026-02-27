import Foundation
import SwiftUI

/// A single plug-in entry as reported by `pluginkit -mvvvv`.
///
/// Each instance represents one plug-in with its metadata fields parsed
/// from the verbose `pluginkit` output. The ``uuid`` property doubles as
/// the stable ``Identifiable/id`` so that SwiftUI can track rows across
/// refreshes without losing table selection state.
struct PluginInfo: Identifiable, Sendable {
    /// The stable identity of this plug-in, equal to ``uuid``.
    var id: String { uuid }

    /// The user election state prefix parsed from the header line.
    let electionState: PluginElectionState

    /// The CFBundleIdentifier of the plug-in (e.g. `com.apple.tips.Widget`).
    let bundleIdentifier: String

    /// The plug-in version string shown in parentheses, which may be `(null)`.
    let version: String

    /// The absolute file-system path to the `.appex` bundle.
    let path: String

    /// The unique identifier assigned to this plug-in by the system.
    let uuid: String

    /// The registration timestamp reported by `pluginkit`.
    let timestamp: String

    /// The extension point SDK identifier (e.g. `com.apple.widgetkit-extension`).
    let sdk: String

    /// The user-facing display name of the plug-in.
    let displayName: String

    /// The abbreviated display name of the plug-in.
    let shortName: String

    /// The display name of the parent application, if the plug-in is embedded inside one.
    let parentName: String?
}
