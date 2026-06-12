import Foundation

public struct SavedLocationsStore: Sendable {
    private let defaultsSuiteName: String?
    private let locationsKey: String
    private let selectionKey: String

    public init(
        defaultsSuiteName: String? = nil,
        locationsKey: String = "weather.saved_locations",
        selectionKey: String = "weather.selected_location_id"
    ) {
        self.defaultsSuiteName = defaultsSuiteName
        self.locationsKey = locationsKey
        self.selectionKey = selectionKey
    }

    public func loadLocations() -> [LocationModel] {
        guard let data = defaults.data(forKey: locationsKey) else { return [] }
        return (try? JSONDecoder().decode([LocationModel].self, from: data)) ?? []
    }

    public func saveLocations(_ locations: [LocationModel]) {
        guard let data = try? JSONEncoder().encode(locations) else { return }
        defaults.set(data, forKey: locationsKey)
    }

    public func loadSelectedLocationID() -> String {
        defaults.string(forKey: selectionKey) ?? LocationModel.currentLocationID
    }

    public func saveSelectedLocationID(_ id: String) {
        defaults.set(id, forKey: selectionKey)
    }

    private var defaults: UserDefaults {
        if let defaultsSuiteName, let suite = UserDefaults(suiteName: defaultsSuiteName) {
            return suite
        }
        return .standard
    }
}
