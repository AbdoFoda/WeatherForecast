import WeatherCore

final class MockSavedLocationsStore: SavedLocationsStoring, @unchecked Sendable {
    var storedLocations: [LocationModel]
    var storedSelectionID: String

    init(locations: [LocationModel] = [], selectionID: String = LocationModel.currentLocationID) {
        storedLocations = locations
        storedSelectionID = selectionID
    }

    func loadLocations() -> [LocationModel] { storedLocations }
    func saveLocations(_ locations: [LocationModel]) { storedLocations = locations }
    func loadSelectedLocationID() -> String { storedSelectionID }
    func saveSelectedLocationID(_ id: String) { storedSelectionID = id }
}
