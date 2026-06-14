#if DEBUG
import Foundation
import WeatherCore

actor UITestWeatherService: WeatherServiceProtocol {
    private let offline: Bool
    private let decoder = JSONDecoder()

    init(offline: Bool) {
        self.offline = offline
    }

    func fetchCurrentWeather(lat: Double, lon: Double) async throws -> CurrentWeatherResponse {
        try guardOnline()
        return try decoder.decode(
            CurrentWeatherResponse.self,
            from: UITestWeatherFixtures.currentWeatherData(lat: lat, lon: lon)
        )
    }

    func fetchForecast(lat: Double, lon: Double) async throws -> ForecastResponse {
        try guardOnline()
        return try decoder.decode(
            ForecastResponse.self,
            from: UITestWeatherFixtures.forecastData(lat: lat, lon: lon)
        )
    }

    func fetchAirPollution(lat: Double, lon: Double) async throws -> AirPollutionResponse {
        try guardOnline()
        return try decoder.decode(
            AirPollutionResponse.self,
            from: UITestWeatherFixtures.airPollutionData(lat: lat, lon: lon)
        )
    }

    private func guardOnline() throws {
        if offline { throw WeatherError.offline }
    }
}
#endif
