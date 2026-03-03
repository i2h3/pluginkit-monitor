import SwiftUI

/// The application entry point for PluginKit Monitor.
///
/// Presents a single window containing a ``ContentView`` that lists all
/// system plug-ins reported by `pluginkit -mvvvv`.
@main
struct PluginKitMonitorApp: App {
    var body: some Scene {
        Window("PluginKit Monitor", id: "main") {
            ContentView()
        }
        .defaultSize(width: 1200, height: 700)
    }
}
