import XCTest
@testable import WeatherCore

final class LocationModelTests: XCTestCase {
    func test_currentLocation_usesSentinelIdentifier() {
        let current = LocationModel.currentLocation
        XCTAssertEqual(current.id, LocationModel.currentLocationID)
        XCTAssertEqual(current.lat, 0)
        XCTAssertEqual(current.lon, 0)
        XCTAssertNil(current.country)
    }

    func test_displayTitle_appendsCountryWhenPresent() {
        let berlin = LocationModel(id: "berlin", name: "Berlin", lat: 52.52, lon: 13.40, country: "DE")
        XCTAssertEqual(berlin.displayTitle, "Berlin, DE")
    }

    func test_displayTitle_omitsCountryWhenMissingOrEmpty() {
        let noCountry = LocationModel(id: "x", name: "Atlantis", lat: 0, lon: 0, country: nil)
        let emptyCountry = LocationModel(id: "y", name: "Atlantis", lat: 0, lon: 0, country: "")
        XCTAssertEqual(noCountry.displayTitle, "Atlantis")
        XCTAssertEqual(emptyCountry.displayTitle, "Atlantis")
    }

    func test_id_formatsCoordinatesToFourDecimals() {
        XCTAssertEqual(LocationModel.id(lat: 52.5200123, lon: 13.405), "52.5200,13.4050")
    }
}
