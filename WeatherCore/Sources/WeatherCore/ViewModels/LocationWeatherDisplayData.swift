import Foundation

public struct LocationWeatherDisplayData: Sendable {
    public let cityName: String
    public let countryCode: String
    public let currentTemperature: String
    public let feelsLike: String
    public let tempRange: String
    public let weatherDescription: String
    public let iconURL: URL
    public let humidity: String
    public let pressure: String
    public let windSpeed: String
    public let visibility: String
    public let sunrise: String
    public let sunset: String
    public let aqi: String
    public let pm25: String
    public let cloudCoverage: String
    
    public let hourlyItems: [HourlyDisplayItem]
    public let tiles: [TileDisplayItem]
}

public struct HourlyDisplayItem: Sendable {
    public let time: String
    public let temperature: String
    public let iconURL: URL
    public let temperatureDotY: CGFloat
    public let isCurrentHour: Bool
    public let dayLabel: String?
    public let precipitationChance: String?
}

public struct TileDisplayItem: Sendable {
    public let id: String
    public let title: String
    public let value: String
    public let subtitle: String?
    public let tileSize: TileSize
    
    public enum TileSize: Sendable {
        case standard, wide, tall
    }
}
