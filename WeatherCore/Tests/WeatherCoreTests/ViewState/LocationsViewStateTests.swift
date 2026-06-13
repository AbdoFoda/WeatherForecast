import XCTest
@testable import WeatherCore

final class LocationsViewStateTests: XCTestCase {
    func test_sectionCount_isAlwaysTwo() {
        let sut = LocationsViewState.initial
        XCTAssertEqual(sut.sectionCount, 2)
    }

    func test_numberOfRows_currentSectionHasSingleRow() {
        let paris = LocationModel(id: "paris", name: "Paris", lat: 48.85, lon: 2.35, country: "FR")
        let sut = LocationsViewState(savedLocations: [paris], selectedLocationID: "paris")

        XCTAssertEqual(sut.numberOfRows(in: 0), 1)
        XCTAssertEqual(sut.numberOfRows(in: 1), 1)
    }

    func test_row_currentLocation_reflectsSelection() {
        let sut = LocationsViewState(
            savedLocations: [],
            selectedLocationID: LocationModel.currentLocationID
        )

        XCTAssertEqual(
            sut.row(at: LocationsIndexPath(section: 0, row: 0)),
            .currentLocation(isSelected: true)
        )
    }

    func test_row_savedLocation_reflectsSelection() {
        let paris = LocationModel(id: "paris", name: "Paris", lat: 48.85, lon: 2.35, country: "FR")
        let sut = LocationsViewState(savedLocations: [paris], selectedLocationID: "paris")

        XCTAssertEqual(
            sut.row(at: LocationsIndexPath(section: 1, row: 0)),
            .saved(paris, isSelected: true)
        )
    }

    func test_selection_savedRow_returnsSavedLocation() {
        let paris = LocationModel(id: "paris", name: "Paris", lat: 48.85, lon: 2.35, country: "FR")
        let sut = LocationsViewState(savedLocations: [paris], selectedLocationID: "paris")

        XCTAssertEqual(
            sut.selection(for: LocationsIndexPath(section: 1, row: 0)),
            .saved(paris)
        )
    }

    func test_editAndMove_allowedOnlyForSavedSection() {
        let paris = LocationModel(id: "paris", name: "Paris", lat: 48.85, lon: 2.35, country: "FR")
        let sut = LocationsViewState(savedLocations: [paris], selectedLocationID: "paris")

        XCTAssertFalse(sut.canEditRow(at: LocationsIndexPath(section: 0, row: 0)))
        XCTAssertFalse(sut.canMoveRow(at: LocationsIndexPath(section: 0, row: 0)))
        XCTAssertTrue(sut.canEditRow(at: LocationsIndexPath(section: 1, row: 0)))
        XCTAssertTrue(sut.canMoveRow(at: LocationsIndexPath(section: 1, row: 0)))
    }
}
