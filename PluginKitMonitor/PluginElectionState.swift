import SwiftUI

/// The user election state of a plug-in as reported by `pluginkit`.
///
/// Each plug-in listed by `pluginkit -m` may be prefixed with a single character
/// indicating whether the user has elected to use, ignore, debug, or supersede it.
/// When no prefix is present the election state is ``none``.
enum PluginElectionState: String, Sendable {
    /// The user has elected to use the plug-in.
    case elected = "+"

    /// The user has elected to ignore the plug-in.
    case ignored = "-"

    /// The user has elected to use the plug-in for debugger use.
    case debugger = "!"

    /// The plug-in is superseded by another plug-in.
    case superseded = "="

    /// Unknown user election state.
    case unknown = "?"

    /// No election state prefix was present in the output.
    case none = ""

    /// The SF Symbol name used to represent this state in the UI.
    var symbolName: String {
        switch self {
        case .debugger:
            "ladybug.slash.circle.fill"
        case .elected:
            "checkmark.circle.fill"
        case .none:
            "circle"
        case .ignored:
            "xmark.circle.fill"
        case .superseded:
            "clock.circle.fill"
        case .unknown:
            "questionmark.circle.fill"
        }
    }

    /// The color used to tint the status symbol.
    var color: Color {
        switch self {
        case .elected:
            .green
        case .ignored:
            .red
        case .debugger:
            .blue
        case .superseded:
            .secondary
        case .unknown:
            .orange
        case .none:
            .secondary
        }
    }

    /// A human-readable label describing the election state.
    var label: String {
        switch self {
        case .elected:
            "Elected"
        case .ignored:
            "Ignored"
        case .debugger:
            "Debugger"
        case .superseded:
            "Superseded"
        case .unknown:
            "Unknown"
        case .none:
            "Default"
        }
    }
}
