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
            main: MainWeather(
                temp: 20,
                feelsLike: 20,
                tempMin: 15,
                tempMax: 25,
                pressure: 1013,
                seaLevel: 1013,
                grndLevel: 1009,
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
            name: "Mock City"
        )
    }

    func fetchForecast(lat: Double, lon: Double) async throws -> ForecastResponse {
        if shouldFail { throw failure }
        return ForecastResponse(
            cod: "200",
            message: nil,
            cnt: 0,
            list: [],
            city: ForecastCity(
                id: 1,
                name: "Mock City",
                coord: Coordinate(lat: lat, lon: lon),
                country: "DE",
                population: nil,
                timezone: 0,
                sunrise: nil,
                sunset: nil
            )
        )
    }

    func fetchAirPollution(lat: Double, lon: Double) async throws -> AirPollutionResponse {
        if shouldFail { throw failure }
        return AirPollutionResponse(coord: Coordinate(lat: lat, lon: lon), list: [])
    }
}
