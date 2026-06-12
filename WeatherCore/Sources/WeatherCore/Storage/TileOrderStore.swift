import Foundation

public struct TileOrderStore: Sendable {
    private let defaultsSuiteName: String?
    private let orderKey: String
    private let hiddenKey: String

    public init(
        defaultsSuiteName: String? = nil,
        orderKey: String = "weather.tile_order",
        hiddenKey: String = "weather.tile_hidden"
    ) {
        self.defaultsSuiteName = defaultsSuiteName
        self.orderKey = orderKey
        self.hiddenKey = hiddenKey
    }

    public func loadOrder() -> [TileKind] {
        guard let data = defaults.data(forKey: orderKey),
              let rawValues = try? JSONDecoder().decode([String].self, from: data) else {
            return TileKind.allCases
        }

        let stored = rawValues.compactMap(TileKind.init(rawValue:))
        guard !stored.isEmpty else { return TileKind.allCases }
        return mergeMissingKinds(into: stored)
    }

    public func saveOrder(_ order: [TileKind]) {
        let rawValues = order.map(\.rawValue)
        guard let data = try? JSONEncoder().encode(rawValues) else { return }
        defaults.set(data, forKey: orderKey)
    }

    public func loadHiddenKinds() -> Set<TileKind> {
        guard let data = defaults.data(forKey: hiddenKey),
              let rawValues = try? JSONDecoder().decode([String].self, from: data) else {
            return []
        }
        return Set(rawValues.compactMap(TileKind.init(rawValue:)))
    }

    public func saveHiddenKinds(_ kinds: Set<TileKind>) {
        let rawValues = kinds.map(\.rawValue).sorted()
        guard let data = try? JSONEncoder().encode(rawValues) else { return }
        defaults.set(data, forKey: hiddenKey)
    }

    private func mergeMissingKinds(into stored: [TileKind]) -> [TileKind] {
        var result = stored
        for kind in TileKind.allCases where !result.contains(kind) {
            result.append(kind)
        }
        return result
    }

    private var defaults: UserDefaults {
        if let defaultsSuiteName, let suite = UserDefaults(suiteName: defaultsSuiteName) {
            return suite
        }
        return .standard
    }
}
