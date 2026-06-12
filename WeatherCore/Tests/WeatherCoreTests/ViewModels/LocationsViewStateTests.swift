import XCTest
@testable import WeatherCore

final class LocationsViewStateTests: XCTestCase {
    func test_sectionCount_withoutSearchQuery_isTwo() {
        let sut = LocationsViewState.initial
        XCTAssertEqual(sut.sectionCount, 2)
    }

    func test_sectionCount_withSearchQuery_isOne() {
        let sut = LocationsViewState(
            savedLocations: [],
            selectedLocationID: LocationModel.currentLocationID,
            searchQuery: "Lon",
            searchResults: []
        )
        XCTAssertEqual(sut.sectionCount, 1)
    }

    func test_clearingSearchQuery_dropsSearchSection() {
        let searching = LocationsViewState(
            savedLocations: [],
            selectedLocationID: LocationModel.currentLocationID,
            searchQuery: "Lon",
            searchResults: [LocationModel(id: "1", name: "London", lat: 51.5, lon: -0.12, country: "GB")]
        )
        let cleared = LocationsViewState(
            savedLocations: [],
            selectedLocationID: LocationModel.currentLocationID,
            searchQuery: "",
            searchResults: []
        )

        XCTAssertEqual(searching.sectionCount, 1)
        XCTAssertEqual(cleared.sectionCount, 2)
    }

    func test_searchResults_useFirstSectionWhileSearching() {
        let london = LocationModel(id: "1", name: "London", lat: 51.5, lon: -0.12, country: "GB")
        let sut = LocationsViewState(
            savedLocations: [],
            selectedLocationID: LocationModel.currentLocationID,
            searchQuery: "Lon",
            searchResults: [london]
        )

        XCTAssertEqual(sut.row(at: LocationsIndexPath(section: 0, row: 0)), .search(london))
    }

    func test_row_currentLocation_reflectsSelection() {
        let sut = LocationsViewState(
            savedLocations: [],
            selectedLocationID: LocationModel.currentLocationID,
            searchQuery: "",
            searchResults: []
        )

        XCTAssertEqual(
            sut.row(at: LocationsIndexPath(section: 0, row: 0)),
            .currentLocation(isSelected: true)
        )
    }

    func test_selection_savedRow_returnsSavedLocation() {
        let paris = LocationModel(id: "paris", name: "Paris", lat: 48.85, lon: 2.35, country: "FR")
        let sut = LocationsViewState(
            savedLocations: [paris],
            selectedLocationID: "paris",
            searchQuery: "",
            searchResults: []
        )

        XCTAssertEqual(
            sut.selection(for: LocationsIndexPath(section: 1, row: 0)),
            .saved(paris)
        )
    }
}
