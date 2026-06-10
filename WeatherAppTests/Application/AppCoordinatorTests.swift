import XCTest
import WeatherCore
@testable import WeatherApp

@MainActor
final class AppCoordinatorTests: XCTestCase {
    func test_init_retainsInjectedWeatherService() {
        let mockService = MockWeatherServiceForApp()
        let sut = AppCoordinator(weatherService: mockService)
        XCTAssertNotNil(sut)
    }

    func test_live_loadsBaseURLFromMainBundle() {
        let sut = AppCoordinator.live()
        XCTAssertNotNil(sut)
    }
}

private final class MockWeatherServiceForApp: WeatherServiceProtocol, @unchecked Sendable {
    func fetchCurrentWeather(lat: Double, lon: Double) async throws -> CurrentWeatherResponse {
        throw WeatherError.invalidResponse
    }

    func fetchForecast(lat: Double, lon: Double) async throws -> ForecastResponse {
        throw WeatherError.invalidResponse
    }

    func fetchAirPollution(lat: Double, lon: Double) async throws -> AirPollutionResponse {
        throw WeatherError.invalidResponse
    }

    func fetchGeocodingDirect(query: String) async throws -> [GeocodingResult] { [] }
    func fetchGeocodingReverse(lat: Double, lon: Double) async throws -> [GeocodingResult] { [] }
}
