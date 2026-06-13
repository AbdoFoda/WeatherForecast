import XCTest
import Synchronization
@testable import WeatherCore

final class MockSummaryWeatherService: WeatherServiceProtocol, @unchecked Sendable {
    private struct State {
        var shouldFail = false
        var callCount = 0
    }

    private let state = Mutex(State())
    var fetchExpectation: XCTestExpectation?

    var shouldFail: Bool {
        get { state.withLock { $0.shouldFail } }
        set { state.withLock { $0.shouldFail = newValue } }
    }

    var callCount: Int {
        state.withLock { $0.callCount }
    }

    func resetCallCount() {
        state.withLock { $0.callCount = 0 }
    }

    func fetchCurrentWeather(lat: Double, lon: Double) async throws -> CurrentWeatherResponse {
        let fail = state.withLock { state -> Bool in
            state.callCount += 1
            return state.shouldFail
        }
        fetchExpectation?.fulfill()
        if fail { throw WeatherError.invalidResponse }
        return CurrentWeatherResponse(
            coord: Coordinate(lat: lat, lon: lon),
            weather: [WeatherCondition(id: 800, main: "Clear", description: "clear sky", icon: "01d")],
            main: MainWeather(
                temp: 20,
                feelsLike: 20,
                tempMin: 15,
                tempMax: 25,
                pressure: 1013,
                seaLevel: nil,
                grndLevel: nil,
                humidity: 50
            ),
            visibility: nil,
            wind: nil,
            clouds: nil,
            rain: nil,
            snow: nil,
            dt: 0,
            sys: Sys(type: nil, id: nil, country: "DE", sunrise: 0, sunset: 0),
            timezone: 0,
            id: 1,
            name: "Berlin"
        )
    }

    func fetchForecast(lat: Double, lon: Double) async throws -> ForecastResponse {
        throw WeatherError.invalidResponse
    }

    func fetchAirPollution(lat: Double, lon: Double) async throws -> AirPollutionResponse {
        throw WeatherError.invalidResponse
    }
}
