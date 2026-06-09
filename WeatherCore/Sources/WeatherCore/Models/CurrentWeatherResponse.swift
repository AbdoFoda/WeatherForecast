import Foundation

public struct CurrentWeatherResponse: Decodable, Sendable {
    public let coord: Coordinate
    public let weather: [WeatherCondition]
    public let main: MainWeather
    public let visibility: Int?
    public let wind: Wind?
    public let clouds: Clouds?
    public let rain: Precipitation?
    public let snow: Precipitation?
    public let dt: TimeInterval
    public let sys: Sys
    public let timezone: Int
    public let id: Int
    public let name: String
}
