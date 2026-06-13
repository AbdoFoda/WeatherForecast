import Foundation
@testable import WeatherCore

final class MockSavedLocationsStore: SavedLocationsStoring, @unchecked Sendable {
    var storedLocations: [LocationModel]
    var storedSelectionID: String
    private(set) var saveLocationsCallCount = 0
    private(set) var savedSelectionIDs: [String] = []

    init(locations: [LocationModel] = [], selectionID: String = LocationModel.currentLocationID) {
        storedLocations = locations
        storedSelectionID = selectionID
    }

    func loadLocations() -> [LocationModel] { storedLocations }

    func saveLocations(_ locations: [LocationModel]) {
        storedLocations = locations
        saveLocationsCallCount += 1
    }

    func loadSelectedLocationID() -> String { storedSelectionID }

    func saveSelectedLocationID(_ id: String) {
        storedSelectionID = id
        savedSelectionIDs.append(id)
    }
}
