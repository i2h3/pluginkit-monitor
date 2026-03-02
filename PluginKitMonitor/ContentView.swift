import SwiftUI

/// The main view displaying a searchable, sortable table of all plug-ins
/// reported by `pluginkit -mvvvv`.
///
/// The table refreshes automatically every second via the underlying
/// ``PluginKitMonitorViewModel`` and supports multi-row selection as well as
/// a toolbar search field that filters on bundle identifier, path, display
/// name, short name, and parent name.
struct ContentView: View {
    /// The view model that owns the plug-in data and refresh timer.
    @StateObject private var viewModel = PluginKitMonitorViewModel()

    /// The set of currently selected row identifiers (plug-in UUIDs).
    @State private var selection: Set<PluginInfo.ID> = []

    var body: some View {
        Table(viewModel.filteredPlugins, selection: $selection, sortOrder: $viewModel.sortOrder) {
            TableColumn("Status") { plugin in
                Image(systemName: plugin.electionState.symbolName)
                    .foregroundStyle(plugin.electionState.color)
                    .help(plugin.electionState.label)
            }
            .width(min: 30, ideal: 50, max: 60)

            TableColumn("Bundle Identifier", value: \.bundleIdentifier)
                .width(min: 100, ideal: 400)

            TableColumn("Version", value: \.version)
                .width(min: 50, ideal: 70)

            TableColumn("Path", value: \.path)
                .width(min: 100, ideal: 400)

            TableColumn("UUID", value: \.uuid)
                .width(min: 100, ideal: 300)

            TableColumn("Timestamp", value: \.timestamp)
                .width(min: 100, ideal: 180)

            TableColumn("SDK", value: \.sdk)
                .width(min: 100, ideal: 200)

            TableColumn("Display Name", value: \.displayName)
                .width(min: 100, ideal: 200)

            TableColumn("Short Name", value: \.shortName)
                .width(min: 100, ideal: 200)

            TableColumn("Parent Name") { plugin in
                Text(plugin.parentName ?? "")
            }
            .width(min: 100, ideal: 200)
        }
        .searchable(text: $viewModel.searchText, prompt: "Filter plugins")
        .onChange(of: viewModel.sortOrder) {
            viewModel.sort(using: viewModel.sortOrder)
        }
        .onAppear {
            viewModel.startMonitoring()
        }
        .onDisappear {
            viewModel.stopMonitoring()
        }
    }
}

#Preview {
    ContentView()
}
