#if DEBUG
import Foundation
import Synchronization
import WeatherCore

final class UITestSavedLocationsStore: SavedLocationsStoring, @unchecked Sendable {
    private struct State {
        var locations: [LocationModel]
        var selectionID: String
    }

    private let state: Mutex<State>

    init(locations: [LocationModel], selectionID: String) {
        state = Mutex(State(locations: locations, selectionID: selectionID))
    }

    func loadLocations() -> [LocationModel] {
        state.withLock { $0.locations }
    }

    func saveLocations(_ locations: [LocationModel]) {
        state.withLock { $0.locations = locations }
    }

    func loadSelectedLocationID() -> String {
        state.withLock { $0.selectionID }
    }

    func saveSelectedLocationID(_ id: String) {
        state.withLock { $0.selectionID = id }
    }
}
#endif
