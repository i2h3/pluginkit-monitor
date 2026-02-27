import Foundation
import Combine

/// Drives the plug-in monitor UI by periodically executing `pluginkit -mvvvv`
/// and publishing the parsed results.
///
/// The view model starts a one-second repeating timer when ``startMonitoring()``
/// is called and stops it on ``stopMonitoring()``. The published ``plugins``
/// array is always kept sorted according to ``sortOrder``, and
/// ``filteredPlugins`` applies the current ``searchText`` on top.
@MainActor
final class PluginKitMonitorViewModel: ObservableObject {
    /// All plug-ins from the most recent `pluginkit` invocation, sorted by ``sortOrder``.
    @Published var plugins: [PluginInfo] = []

    /// The current search string entered by the user.
    @Published var searchText = ""

    /// The active column sort descriptors, defaulting to ascending bundle identifier.
    @Published var sortOrder: [KeyPathComparator<PluginInfo>] = [
        .init(\.bundleIdentifier, order: .forward)
    ]

    /// The subset of ``plugins`` whose searchable fields match ``searchText``.
    ///
    /// Filtering is applied case-insensitively against the bundle identifier,
    /// path, display name, short name, and parent name. When ``searchText`` is
    /// empty the full ``plugins`` array is returned.
    var filteredPlugins: [PluginInfo] {
        guard !searchText.isEmpty else { return plugins }
        let query = searchText.localizedLowercase
        return plugins.filter { plugin in
            plugin.bundleIdentifier.localizedCaseInsensitiveContains(query)
                || plugin.path.localizedCaseInsensitiveContains(query)
                || plugin.displayName.localizedCaseInsensitiveContains(query)
                || plugin.shortName.localizedCaseInsensitiveContains(query)
                || (plugin.parentName?.localizedCaseInsensitiveContains(query) ?? false)
        }
    }

    /// The timer responsible for periodic refreshes.
    private var timer: Timer?

    /// Performs an initial refresh and starts the one-second repeating timer.
    func startMonitoring() {
        refresh()
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.refresh()
            }
        }
    }

    /// Invalidates the repeating timer and stops further refreshes.
    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }

    /// Fetches the latest `pluginkit` output and replaces ``plugins``.
    private func refresh() {
        Task.detached {
            let fetched = PluginKitParser.runPluginKit()

            Task { @MainActor [weak self] in
                guard let self = self else {
                    return
                }

                self.plugins = fetched.sorted(using: self.sortOrder)
            }
        }
    }

    /// Re-sorts the current ``plugins`` array using the given sort descriptors.
    ///
    /// - Parameter newOrder: The column sort descriptors to apply.
    func sort(using newOrder: [KeyPathComparator<PluginInfo>]) {
        sortOrder = newOrder
        plugins.sort(using: sortOrder)
    }
}
