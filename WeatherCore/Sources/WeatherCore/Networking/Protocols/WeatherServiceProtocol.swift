import Foundation

public protocol WeatherServiceProtocol: Sendable {
    func fetchCurrentWeather(lat: Double, lon: Double) async throws -> CurrentWeatherResponse
    func fetchForecast(lat: Double, lon: Double) async throws -> ForecastResponse
    func fetchAirPollution(lat: Double, lon: Double) async throws -> AirPollutionResponse
}
