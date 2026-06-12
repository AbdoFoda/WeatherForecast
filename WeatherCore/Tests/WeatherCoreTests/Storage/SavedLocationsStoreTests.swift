import XCTest
@testable import WeatherCore

final class SavedLocationsStoreTests: XCTestCase {
    private let suiteName = "SavedLocationsStoreTests"

    override func setUp() {
        super.setUp()
        UserDefaults(suiteName: suiteName)?.removePersistentDomain(forName: suiteName)
    }

    func test_loadLocations_emptyByDefault() {
        let sut = SavedLocationsStore(defaultsSuiteName: suiteName)
        XCTAssertTrue(sut.loadLocations().isEmpty)
    }

    func test_saveAndLoadLocations_roundTrip() {
        let sut = SavedLocationsStore(defaultsSuiteName: suiteName)
        let berlin = LocationModel(id: "1", name: "Berlin", lat: 52.52, lon: 13.40, country: "DE")
        let paris = LocationModel(id: "2", name: "Paris", lat: 48.85, lon: 2.35, country: "FR")

        sut.saveLocations([berlin, paris])

        XCTAssertEqual(sut.loadLocations(), [berlin, paris])
    }

    func test_selectedLocationID_defaultsToCurrentLocation() {
        let sut = SavedLocationsStore(defaultsSuiteName: suiteName)
        XCTAssertEqual(sut.loadSelectedLocationID(), LocationModel.currentLocationID)
    }

    func test_saveSelectedLocationID_persistsValue() {
        let sut = SavedLocationsStore(defaultsSuiteName: suiteName)
        sut.saveSelectedLocationID("52.5200,13.4000")
        XCTAssertEqual(sut.loadSelectedLocationID(), "52.5200,13.4000")
    }
}
