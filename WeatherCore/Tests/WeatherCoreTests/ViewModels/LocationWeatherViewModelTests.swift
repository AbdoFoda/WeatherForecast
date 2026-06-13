import XCTest
@testable import WeatherCore

@MainActor
final class LocationWeatherViewModelTests: XCTestCase {
    private var cacheDirectory: URL!

    override func setUp() {
        super.setUp()
        cacheDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: cacheDirectory)
        super.tearDown()
    }

    private func makeViewModel(service: MockWeatherService = MockWeatherService()) -> LocationWeatherViewModel {
        LocationWeatherViewModel(
            weatherService: service,
            diskCache: WeatherDiskCache(directoryURL: cacheDirectory)
        )
    }

    func test_loadWeather_successStateTransition() async {
        let mockService = MockWeatherService()
        let sut = makeViewModel(service: mockService)

        var states: [String] = []
        let expectation = XCTestExpectation(description: "Wait for loaded state")

        sut.onStateChange = { state in
            switch state {
            case .loading:
                states.append("loading")
            case .loaded(_, nil):
                states.append("loaded")
                expectation.fulfill()
            default:
                break
            }
        }

        await sut.loadWeather(lat: 0, lon: 0)

        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertEqual(states, ["loading", "loaded"])
    }

    func test_loadWeather_withoutCache_becomesUnavailable() async {
        let mockService = MockWeatherService()
        mockService.shouldFail = true
        let sut = makeViewModel(service: mockService)

        var states: [String] = []
        let expectation = XCTestExpectation(description: "Wait for unavailable state")

        sut.onStateChange = { state in
            switch state {
            case .loading:
                states.append("loading")
            case .unavailable(.unavailable):
                states.append("unavailable")
                expectation.fulfill()
            default:
                break
            }
        }

        await sut.loadWeather(lat: 0, lon: 0)

        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertEqual(states, ["loading", "unavailable"])
    }

    func test_refresh_withCacheAndServerError_keepsCachedData() async {
        let mockService = MockWeatherService()
        let sut = makeViewModel(service: mockService)

        let loadExpectation = XCTestExpectation(description: "Wait for initial load")
        sut.onStateChange = { state in
            if case .loaded = state {
                loadExpectation.fulfill()
            }
        }

        await sut.loadWeather(lat: 0, lon: 0)
        await fulfillment(of: [loadExpectation], timeout: 1.0)

        mockService.shouldFail = true
        let refreshExpectation = XCTestExpectation(description: "Wait for cached reload")

        sut.onStateChange = { state in
            if case .loaded(_, .unavailable) = state {
                refreshExpectation.fulfill()
            }
        }

        await sut.refresh(lat: 0, lon: 0)
        await fulfillment(of: [refreshExpectation], timeout: 1.0)
    }

    func test_refresh_withCacheAndOffline_showsOfflineNotice() async {
        let mockService = MockWeatherService()
        let sut = makeViewModel(service: mockService)

        let loadExpectation = XCTestExpectation(description: "Wait for initial load")
        sut.onStateChange = { state in
            if case .loaded = state {
                loadExpectation.fulfill()
            }
        }

        await sut.loadWeather(lat: 0, lon: 0)
        await fulfillment(of: [loadExpectation], timeout: 1.0)

        mockService.shouldFail = true
        mockService.failure = WeatherError.offline

        let refreshExpectation = XCTestExpectation(description: "Wait for offline cached reload")

        sut.onStateChange = { state in
            if case .loaded(_, .offline) = state {
                refreshExpectation.fulfill()
            }
        }

        await sut.refresh(lat: 0, lon: 0)
        await fulfillment(of: [refreshExpectation], timeout: 1.0)
    }
}

extension LocationWeatherViewModelTests {
    func test_saveTileOrder_persistsWithoutRepublishingLoadedState() async {
        let suiteName = "LocationWeatherViewModelTileOrderTests"
        UserDefaults(suiteName: suiteName)?.removePersistentDomain(forName: suiteName)

        let mockService = MockWeatherService()
        let store = TileOrderStore(defaultsSuiteName: suiteName)
        let sut = LocationWeatherViewModel(
            weatherService: mockService,
            tileOrderStore: store,
            diskCache: WeatherDiskCache(directoryURL: cacheDirectory)
        )

        let loadExpectation = XCTestExpectation(description: "Wait for initial load")
        var loadedTiles: [TileDisplayItem] = []
        sut.onStateChange = { state in
            if case .loaded(let displayData, nil) = state {
                loadedTiles = displayData.tiles
                loadExpectation.fulfill()
            }
        }

        await sut.loadWeather(lat: 0, lon: 0)
        await fulfillment(of: [loadExpectation], timeout: 1.0)

        let existingKinds = loadedTiles.compactMap { TileKind(rawValue: $0.id) }
        let customOrder: [TileKind] = [.wind, .humidity, .feelsLike] + existingKinds.filter {
            ![.wind, .humidity, .feelsLike].contains($0)
        }

        var publishCount = 0
        sut.onStateChange = { _ in
            publishCount += 1
        }

        sut.saveTileOrder(customOrder)

        XCTAssertEqual(publishCount, 0)
        XCTAssertEqual(store.loadOrder().prefix(customOrder.count).map { $0 }, customOrder)
    }

    func test_saveTileOrder_writesToInjectedTileOrderStore() async {
        let mockService = MockWeatherService()
        let mockStore = MockTileOrderStore()
        let sut = LocationWeatherViewModel(
            weatherService: mockService,
            tileOrderStore: mockStore,
            diskCache: WeatherDiskCache(directoryURL: cacheDirectory)
        )

        let customOrder: [TileKind] = [.wind, .humidity, .feelsLike]
        sut.saveTileOrder(customOrder)

        XCTAssertEqual(mockStore.savedOrders.count, 1)
        XCTAssertEqual(Array(mockStore.order.prefix(customOrder.count)), customOrder)
    }

    func test_hideTile_writesHiddenKindsToInjectedStore() async {
        let mockService = MockWeatherService()
        let mockStore = MockTileOrderStore()
        let sut = LocationWeatherViewModel(
            weatherService: mockService,
            tileOrderStore: mockStore,
            diskCache: WeatherDiskCache(directoryURL: cacheDirectory)
        )

        sut.hideTile(.humidity)

        XCTAssertEqual(mockStore.hidden, [.humidity])
        XCTAssertTrue(sut.hasHiddenTiles)
    }

    func test_showAllTiles_restoresPreviouslyHiddenTile() async {
        let suiteName = "LocationWeatherViewModelRestoreTests"
        UserDefaults(suiteName: suiteName)?.removePersistentDomain(forName: suiteName)

        let mockService = MockWeatherService()
        let store = TileOrderStore(defaultsSuiteName: suiteName)
        let sut = LocationWeatherViewModel(
            weatherService: mockService,
            tileOrderStore: store,
            diskCache: WeatherDiskCache(directoryURL: cacheDirectory)
        )

        let loadExpectation = XCTestExpectation(description: "Wait for initial load")
        var loadedTiles: [TileDisplayItem] = []
        sut.onStateChange = { state in
            if case .loaded(let display, _) = state {
                loadedTiles = display.tiles
                loadExpectation.fulfill()
            }
        }
        await sut.loadWeather(lat: 0, lon: 0)
        await fulfillment(of: [loadExpectation], timeout: 1.0)

        let fullCount = loadedTiles.count
        guard let kindToHide = loadedTiles.compactMap({ TileKind(rawValue: $0.id) }).first else {
            return XCTFail("Expected at least one tile to hide")
        }

        var tilesAfterHide: [TileDisplayItem] = []
        sut.onStateChange = { state in
            if case .loaded(let display, _) = state { tilesAfterHide = display.tiles }
        }
        sut.hideTile(kindToHide)
        XCTAssertEqual(tilesAfterHide.count, fullCount - 1)

        var tilesAfterShowAll: [TileDisplayItem] = []
        sut.onStateChange = { state in
            if case .loaded(let display, _) = state { tilesAfterShowAll = display.tiles }
        }
        sut.showAllTiles()
        XCTAssertEqual(tilesAfterShowAll.count, fullCount)
        XCTAssertTrue(tilesAfterShowAll.contains { $0.id == kindToHide.rawValue })
    }

    func test_loadWeather_showsDiskCacheBeforeFetchCompletes() async {
        let cacheDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: cacheDirectory) }

        let diskCache = WeatherDiskCache(directoryURL: cacheDirectory)
        await diskCache.save(
            lat: 10,
            lon: 20,
            displayData: LocationWeatherDisplayData(
                cityName: "Cached City",
                countryCode: "DE",
                currentTemperature: "10°",
                feelsLike: "Feels like 9°",
                tempRange: "H:12° L:8°",
                weatherDescription: "Cloudy",
                iconURL: nil,
                humidity: "40%",
                pressure: "1010 hPa",
                windSpeed: "2.0 m/s N",
                visibility: "8 km",
                sunrise: "07:00",
                sunset: "19:00",
                aqi: "Good",
                pm25: "4.0 μg/m³",
                cloudCoverage: "50%",
                backgroundScene: .cloudy,
                cloudCoveragePercent: 50,
                windSpeedMetersPerSecond: 2,
                hourlyItems: [],
                tiles: []
            )
        )

        let mockService = MockWeatherService()
        mockService.shouldFail = true
        let sut = LocationWeatherViewModel(weatherService: mockService, diskCache: diskCache)

        var firstLoadedCity: String?
        let expectation = XCTestExpectation(description: "Wait for cached load")
        sut.onStateChange = { state in
            guard firstLoadedCity == nil, case .loaded(let display, _) = state else { return }
            firstLoadedCity = display.cityName
            expectation.fulfill()
        }

        await sut.loadWeather(lat: 10, lon: 20)

        await fulfillment(of: [expectation], timeout: 1.0)
        XCTAssertEqual(firstLoadedCity, "Cached City")
    }

    func test_loadWeather_appliesBarometricAltitudeWhenLocationDetailsMissing() async {
        let mockService = MockWeatherService()
        let sut = makeViewModel(service: mockService)

        var loadedAltitude: String?
        let expectation = XCTestExpectation(description: "Wait for loaded state")
        sut.onStateChange = { state in
            guard case .loaded(let display, nil) = state else { return }
            loadedAltitude = display.altitude
            expectation.fulfill()
        }

        await sut.loadWeather(lat: 52.52, lon: 13.405)
        await fulfillment(of: [expectation], timeout: 1.0)

        XCTAssertNotNil(loadedAltitude)
        XCTAssertTrue(loadedAltitude?.contains("m") == true)
    }

    func test_loadWeather_keepsPostalCodeWhenBarometricAltitudeApplied() async {
        let mockService = MockWeatherService()
        let sut = makeViewModel(service: mockService)
        sut.updateLocationDetails(LocationDetails(postalCode: "10115", altitudeMeters: nil))

        var loadedDisplay: LocationWeatherDisplayData?
        let expectation = XCTestExpectation(description: "Wait for loaded state")
        sut.onStateChange = { state in
            guard case .loaded(let display, nil) = state else { return }
            loadedDisplay = display
            expectation.fulfill()
        }

        await sut.loadWeather(lat: 52.52, lon: 13.405)
        await fulfillment(of: [expectation], timeout: 1.0)

        XCTAssertEqual(loadedDisplay?.postalCode, "10115")
        XCTAssertNotNil(loadedDisplay?.altitude)
    }
}
