import XCTest
@testable import WeatherCore

final class MockWeatherService: WeatherServiceProtocol, @unchecked Sendable {
    var shouldFail = false
    var failure: Error = WeatherError.invalidResponse

    func fetchCurrentWeather(lat: Double, lon: Double) async throws -> CurrentWeatherResponse {
        if shouldFail { throw failure }
        return CurrentWeatherResponse(
            coord: Coordinate(lat: lat, lon: lon),
            weather: [],
            main: MainWeather(temp: 20, feelsLike: 20, tempMin: 15, tempMax: 25, pressure: 1013, seaLevel: nil, grndLevel: nil, humidity: 50),
            visibility: nil,
            wind: nil,
            clouds: nil,
            rain: nil,
            snow: nil,
            dt: 0,
            sys: Sys(type: nil, id: nil, country: "DE", sunrise: 0, sunset: 0),
            timezone: 0,
            id: 1,
            name: "Mock City"
        )
    }

    func fetchForecast(lat: Double, lon: Double) async throws -> ForecastResponse {
        if shouldFail { throw failure }
        return ForecastResponse(cod: "200", message: nil, cnt: 0, list: [], city: ForecastCity(id: 1, name: "Mock City", coord: Coordinate(lat: lat, lon: lon), country: "DE", population: nil, timezone: 0, sunrise: nil, sunset: nil))
    }

    func fetchAirPollution(lat: Double, lon: Double) async throws -> AirPollutionResponse {
        if shouldFail { throw failure }
        return AirPollutionResponse(coord: Coordinate(lat: lat, lon: lon), list: [])
    }

    func fetchGeocodingDirect(query: String) async throws -> [GeocodingResult] { [] }
    func fetchGeocodingReverse(lat: Double, lon: Double) async throws -> [GeocodingResult] { [] }
}

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
            case .unavailable(nil):
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
            if case .loaded(_, nil) = state {
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
        mockService.failure = WeatherError.offline(underlying: URLError(.notConnectedToInternet))

        let refreshExpectation = XCTestExpectation(description: "Wait for offline cached reload")

        sut.onStateChange = { state in
            if case .loaded(_, .offline) = state {
                refreshExpectation.fulfill()
            }
        }

        await sut.refresh(lat: 0, lon: 0)
        await fulfillment(of: [refreshExpectation], timeout: 1.0)
    }

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

    func test_loadWeather_showsDiskCacheBeforeFetchCompletes() async {
        let cacheDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
        defer { try? FileManager.default.removeItem(at: cacheDirectory) }

        let diskCache = WeatherDiskCache(directoryURL: cacheDirectory)
        diskCache.save(
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
}
