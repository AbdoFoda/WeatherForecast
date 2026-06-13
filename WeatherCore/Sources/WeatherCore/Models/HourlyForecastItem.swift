import Foundation

public struct HourlyForecastItem: Decodable, Sendable {
    public let dt: TimeInterval
    public let main: MainWeather
    public let weather: [WeatherCondition]
    public let clouds: Clouds?
    public let wind: Wind?
    public let visibility: Int?
    public let pop: Double?
    public let rain: Precipitation?
    public let snow: Precipitation?
    public let sys: HourlyForecastSys?
    public let dtTxt: String?

    enum CodingKeys: String, CodingKey {
        case dt, main, weather, clouds, wind, visibility, pop, rain, snow, sys
        case dtTxt = "dt_txt"
    }
}
