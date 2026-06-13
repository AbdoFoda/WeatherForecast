import WeatherCore

final class MockWeatherServiceForApp: WeatherServiceProtocol, @unchecked Sendable {
    func fetchCurrentWeather(lat: Double, lon: Double) async throws -> CurrentWeatherResponse {
        throw WeatherError.invalidResponse
    }

    func fetchForecast(lat: Double, lon: Double) async throws -> ForecastResponse {
        throw WeatherError.invalidResponse
    }

    func fetchAirPollution(lat: Double, lon: Double) async throws -> AirPollutionResponse {
        throw WeatherError.invalidResponse
    }
}
