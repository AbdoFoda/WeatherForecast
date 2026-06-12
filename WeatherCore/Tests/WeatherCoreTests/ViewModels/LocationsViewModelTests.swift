import XCTest
@testable import WeatherCore

@MainActor
final class LocationsViewModelTests: XCTestCase {
    private var store: SavedLocationsStore!

    override func setUp() {
        super.setUp()
        let suiteName = "LocationsViewModelTests"
        UserDefaults(suiteName: suiteName)?.removePersistentDomain(forName: suiteName)
        store = SavedLocationsStore(defaultsSuiteName: suiteName)
    }

    func test_load_publishesSavedLocations() {
        let berlin = LocationModel(id: "berlin", name: "Berlin", lat: 52.52, lon: 13.40, country: "DE")
        store.saveLocations([berlin])
        store.saveSelectedLocationID("berlin")

        let sut = LocationsViewModel(store: store)
        var published: LocationsViewState?
        sut.onStateChange = { published = $0 }

        sut.load()

        XCTAssertEqual(published?.savedLocations, [berlin])
        XCTAssertEqual(published?.selectedLocationID, "berlin")
    }

    func test_addLocation_appendsAndSelects() {
        let sut = LocationsViewModel(store: store)
        sut.load()

        sut.addLocation(
            LocationModel(id: "paris", name: "Paris", lat: 48.85, lon: 2.35, country: "FR")
        )

        XCTAssertEqual(sut.state.savedLocations.count, 1)
        XCTAssertEqual(sut.state.savedLocations.first?.name, "Paris")
        XCTAssertEqual(sut.state.selectedLocationID, "paris")
        XCTAssertEqual(store.loadLocations().count, 1)
    }

    func test_addLocation_existingLocation_selectsWithoutDuplicating() {
        let paris = LocationModel(id: "paris", name: "Paris", lat: 48.85, lon: 2.35, country: "FR")
        store.saveLocations([paris])
        store.saveSelectedLocationID(LocationModel.currentLocationID)

        let sut = LocationsViewModel(store: store)
        sut.load()
        sut.addLocation(paris)

        XCTAssertEqual(sut.state.savedLocations.count, 1)
        XCTAssertEqual(sut.state.selectedLocationID, "paris")
    }

    func test_selectRow_savedLocation_updatesSelection() {
        let berlin = LocationModel(id: "berlin", name: "Berlin", lat: 52.52, lon: 13.40, country: "DE")
        store.saveLocations([berlin])

        let sut = LocationsViewModel(store: store)
        sut.load()

        let selection = sut.selectRow(at: LocationsIndexPath(section: 1, row: 0))

        XCTAssertEqual(selection, .saved(berlin))
        XCTAssertEqual(sut.state.selectedLocationID, "berlin")
    }

    func test_removeLocation_resetsSelectionWhenRemovingSelected() {
        let berlin = LocationModel(id: "berlin", name: "Berlin", lat: 52.52, lon: 13.40, country: "DE")
        store.saveLocations([berlin])
        store.saveSelectedLocationID("berlin")

        let sut = LocationsViewModel(store: store)
        sut.load()
        sut.removeLocation(at: 0)

        XCTAssertTrue(sut.state.savedLocations.isEmpty)
        XCTAssertEqual(sut.state.selectedLocationID, LocationModel.currentLocationID)
    }

    func test_moveLocation_reordersSavedLocations() {
        let berlin = LocationModel(id: "berlin", name: "Berlin", lat: 52.52, lon: 13.40, country: "DE")
        let paris = LocationModel(id: "paris", name: "Paris", lat: 48.85, lon: 2.35, country: "FR")
        store.saveLocations([berlin, paris])

        let sut = LocationsViewModel(store: store)
        sut.load()
        sut.moveLocation(from: 0, to: 1)

        XCTAssertEqual(sut.state.savedLocations, [paris, berlin])
        XCTAssertEqual(store.loadLocations(), [paris, berlin])
    }

    func test_selectLocation_atSavedIndex_persistsSelection() {
        let berlin = LocationModel(id: "berlin", name: "Berlin", lat: 52.52, lon: 13.40, country: "DE")
        store.saveLocations([berlin])
        store.saveSelectedLocationID(LocationModel.currentLocationID)

        let sut = LocationsViewModel(store: store)
        sut.load()

        let selection = sut.selectLocation(at: 1)

        XCTAssertEqual(selection, .saved(berlin))
        XCTAssertEqual(sut.state.selectedLocationID, "berlin")
        XCTAssertEqual(store.loadSelectedLocationID(), "berlin")
    }

    func test_selectLocation_atZero_selectsCurrentLocation() {
        let berlin = LocationModel(id: "berlin", name: "Berlin", lat: 52.52, lon: 13.40, country: "DE")
        store.saveLocations([berlin])
        store.saveSelectedLocationID("berlin")

        let sut = LocationsViewModel(store: store)
        sut.load()

        let selection = sut.selectLocation(at: 0)

        XCTAssertEqual(selection, .current)
        XCTAssertEqual(sut.state.selectedLocationID, LocationModel.currentLocationID)
    }

    func test_selectLocation_outOfBounds_returnsNilAndKeepsSelection() {
        let berlin = LocationModel(id: "berlin", name: "Berlin", lat: 52.52, lon: 13.40, country: "DE")
        store.saveLocations([berlin])
        store.saveSelectedLocationID("berlin")

        let sut = LocationsViewModel(store: store)
        sut.load()

        XCTAssertNil(sut.selectLocation(at: 2))
        XCTAssertNil(sut.selectLocation(at: -1))
        XCTAssertEqual(sut.state.selectedLocationID, "berlin")
    }

    func test_state_selectionsAndSelectedIndex_reflectSavedOrder() {
        let berlin = LocationModel(id: "berlin", name: "Berlin", lat: 52.52, lon: 13.40, country: "DE")
        let paris = LocationModel(id: "paris", name: "Paris", lat: 48.85, lon: 2.35, country: "FR")
        store.saveLocations([berlin, paris])
        store.saveSelectedLocationID("paris")

        let sut = LocationsViewModel(store: store)
        sut.load()

        XCTAssertEqual(sut.state.selections, [.current, .saved(berlin), .saved(paris)])
        XCTAssertEqual(sut.state.selectedSelectionIndex, 2)
    }
}
