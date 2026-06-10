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
    func test_loadWeather_successStateTransition() async {
        let mockService = MockWeatherService()
        let sut = LocationWeatherViewModel(weatherService: mockService)

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
        let sut = LocationWeatherViewModel(weatherService: mockService)

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
        let sut = LocationWeatherViewModel(weatherService: mockService)

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
        let sut = LocationWeatherViewModel(weatherService: mockService)

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
}
