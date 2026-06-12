import XCTest
@testable import WeatherCore

@MainActor
final class LocationsViewModelTests: XCTestCase {
    private var store: SavedLocationsStore!
    private var mockService: MockGeocodingWeatherService!

    override func setUp() {
        super.setUp()
        let suiteName = "LocationsViewModelTests"
        UserDefaults(suiteName: suiteName)?.removePersistentDomain(forName: suiteName)
        store = SavedLocationsStore(defaultsSuiteName: suiteName)
        mockService = MockGeocodingWeatherService()
    }

    func test_load_publishesSavedLocations() {
        let berlin = LocationModel(id: "berlin", name: "Berlin", lat: 52.52, lon: 13.40, country: "DE")
        store.saveLocations([berlin])
        store.saveSelectedLocationID("berlin")

        let sut = LocationsViewModel(weatherService: mockService, store: store)
        var published: LocationsViewState?
        sut.onStateChange = { published = $0 }

        sut.load()

        XCTAssertEqual(published?.savedLocations, [berlin])
        XCTAssertEqual(published?.selectedLocationID, "berlin")
    }

    func test_addLocation_appendsAndSelects() {
        let sut = LocationsViewModel(weatherService: mockService, store: store)
        sut.load()

        sut.addLocation(
            LocationModel(id: "paris", name: "Paris", lat: 48.85, lon: 2.35, country: "FR")
        )

        XCTAssertEqual(sut.state.savedLocations.count, 1)
        XCTAssertEqual(sut.state.savedLocations.first?.name, "Paris")
        XCTAssertEqual(sut.state.selectedLocationID, "paris")
        XCTAssertEqual(store.loadLocations().count, 1)
        XCTAssertTrue(sut.state.searchQuery.isEmpty)
    }

    func test_setSearchQuery_shortQuery_clearsResultsWithoutSearchSection() async {
        let sut = LocationsViewModel(weatherService: mockService, store: store)
        sut.load()
        mockService.directResults = [
            GeocodingResult(name: "London", localNames: nil, lat: 51.5, lon: -0.12, country: "GB", state: nil)
        ]
        await sut.setSearchQuery("London")
        XCTAssertEqual(sut.state.sectionCount, 1)

        await sut.setSearchQuery("L")

        XCTAssertEqual(sut.state.sectionCount, 2)
        XCTAssertTrue(sut.state.searchResults.isEmpty)
    }

    func test_setSearchQuery_publishesGeocodingResults() async {
        mockService.directResults = [
            GeocodingResult(name: "London", localNames: nil, lat: 51.5, lon: -0.12, country: "GB", state: nil)
        ]
        let sut = LocationsViewModel(weatherService: mockService, store: store)
        var published: LocationsViewState?
        sut.onStateChange = { published = $0 }

        await sut.setSearchQuery("London")

        XCTAssertEqual(published?.searchResults.count, 1)
        XCTAssertEqual(published?.searchResults.first?.name, "London")
        XCTAssertEqual(published?.sectionCount, 1)
    }

    func test_addLocation_existingLocation_selectsWithoutDuplicating() {
        let paris = LocationModel(id: "paris", name: "Paris", lat: 48.85, lon: 2.35, country: "FR")
        store.saveLocations([paris])
        store.saveSelectedLocationID(LocationModel.currentLocationID)

        let sut = LocationsViewModel(weatherService: mockService, store: store)
        sut.load()
        sut.addLocation(paris)

        XCTAssertEqual(sut.state.savedLocations.count, 1)
        XCTAssertEqual(sut.state.selectedLocationID, "paris")
    }

    func test_selectRow_savedLocation_updatesSelection() {
        let berlin = LocationModel(id: "berlin", name: "Berlin", lat: 52.52, lon: 13.40, country: "DE")
        store.saveLocations([berlin])

        let sut = LocationsViewModel(weatherService: mockService, store: store)
        sut.load()

        let selection = sut.selectRow(at: LocationsIndexPath(section: 1, row: 0))

        XCTAssertEqual(selection, .saved(berlin))
        XCTAssertEqual(sut.state.selectedLocationID, "berlin")
    }

    func test_removeLocation_resetsSelectionWhenRemovingSelected() {
        let berlin = LocationModel(id: "berlin", name: "Berlin", lat: 52.52, lon: 13.40, country: "DE")
        store.saveLocations([berlin])
        store.saveSelectedLocationID("berlin")

        let sut = LocationsViewModel(weatherService: mockService, store: store)
        sut.load()
        sut.removeLocation(at: 0)

        XCTAssertTrue(sut.state.savedLocations.isEmpty)
        XCTAssertEqual(sut.state.selectedLocationID, LocationModel.currentLocationID)
    }

    func test_selectLocation_atSavedIndex_persistsSelection() {
        let berlin = LocationModel(id: "berlin", name: "Berlin", lat: 52.52, lon: 13.40, country: "DE")
        store.saveLocations([berlin])
        store.saveSelectedLocationID(LocationModel.currentLocationID)

        let sut = LocationsViewModel(weatherService: mockService, store: store)
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

        let sut = LocationsViewModel(weatherService: mockService, store: store)
        sut.load()

        let selection = sut.selectLocation(at: 0)

        XCTAssertEqual(selection, .current)
        XCTAssertEqual(sut.state.selectedLocationID, LocationModel.currentLocationID)
    }

    func test_selectLocation_outOfBounds_returnsNilAndKeepsSelection() {
        let berlin = LocationModel(id: "berlin", name: "Berlin", lat: 52.52, lon: 13.40, country: "DE")
        store.saveLocations([berlin])
        store.saveSelectedLocationID("berlin")

        let sut = LocationsViewModel(weatherService: mockService, store: store)
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

        let sut = LocationsViewModel(weatherService: mockService, store: store)
        sut.load()

        XCTAssertEqual(sut.state.selections, [.current, .saved(berlin), .saved(paris)])
        XCTAssertEqual(sut.state.selectedSelectionIndex, 2)
    }
}

@MainActor
private final class MockGeocodingWeatherService: WeatherServiceProtocol, @unchecked Sendable {
    var directResults: [GeocodingResult] = []

    func fetchCurrentWeather(lat: Double, lon: Double) async throws -> CurrentWeatherResponse {
        throw WeatherError.invalidResponse
    }

    func fetchForecast(lat: Double, lon: Double) async throws -> ForecastResponse {
        throw WeatherError.invalidResponse
    }

    func fetchAirPollution(lat: Double, lon: Double) async throws -> AirPollutionResponse {
        throw WeatherError.invalidResponse
    }

    func fetchGeocodingDirect(query: String) async throws -> [GeocodingResult] { directResults }
    func fetchGeocodingReverse(lat: Double, lon: Double) async throws -> [GeocodingResult] { [] }
}
