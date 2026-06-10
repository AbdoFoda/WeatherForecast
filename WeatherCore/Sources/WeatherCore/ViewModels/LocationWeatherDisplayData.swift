import CoreGraphics
import Foundation

public struct LocationWeatherDisplayData: Sendable {
    public let cityName: String
    public let countryCode: String
    public let currentTemperature: String
    public let feelsLike: String
    public let tempRange: String
    public let weatherDescription: String
    public let iconURL: URL?
    public let humidity: String
    public let pressure: String
    public let windSpeed: String
    public let visibility: String
    public let sunrise: String
    public let sunset: String
    public let aqi: String
    public let pm25: String
    public let cloudCoverage: String
    public let backgroundScene: WeatherScene
    public let cloudCoveragePercent: Int
    public let windSpeedMetersPerSecond: Double

    public let hourlyItems: [HourlyDisplayItem]
    public let tiles: [TileDisplayItem]

    public init(
        cityName: String,
        countryCode: String,
        currentTemperature: String,
        feelsLike: String,
        tempRange: String,
        weatherDescription: String,
        iconURL: URL?,
        humidity: String,
        pressure: String,
        windSpeed: String,
        visibility: String,
        sunrise: String,
        sunset: String,
        aqi: String,
        pm25: String,
        cloudCoverage: String,
        backgroundScene: WeatherScene,
        cloudCoveragePercent: Int,
        windSpeedMetersPerSecond: Double,
        hourlyItems: [HourlyDisplayItem],
        tiles: [TileDisplayItem]
    ) {
        self.cityName = cityName
        self.countryCode = countryCode
        self.currentTemperature = currentTemperature
        self.feelsLike = feelsLike
        self.tempRange = tempRange
        self.weatherDescription = weatherDescription
        self.iconURL = iconURL
        self.humidity = humidity
        self.pressure = pressure
        self.windSpeed = windSpeed
        self.visibility = visibility
        self.sunrise = sunrise
        self.sunset = sunset
        self.aqi = aqi
        self.pm25 = pm25
        self.cloudCoverage = cloudCoverage
        self.backgroundScene = backgroundScene
        self.cloudCoveragePercent = cloudCoveragePercent
        self.windSpeedMetersPerSecond = windSpeedMetersPerSecond
        self.hourlyItems = hourlyItems
        self.tiles = tiles
    }
}

public struct HourlyDisplayItem: Sendable {
    public let time: String
    public let temperature: String
    public let iconURL: URL?
    public let temperatureDotY: CGFloat
    public let isCurrentHour: Bool
    public let dayLabel: String?
    public let precipitationChance: String?

    public init(
        time: String,
        temperature: String,
        iconURL: URL?,
        temperatureDotY: CGFloat,
        isCurrentHour: Bool,
        dayLabel: String?,
        precipitationChance: String?
    ) {
        self.time = time
        self.temperature = temperature
        self.iconURL = iconURL
        self.temperatureDotY = temperatureDotY
        self.isCurrentHour = isCurrentHour
        self.dayLabel = dayLabel
        self.precipitationChance = precipitationChance
    }
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

    public init(
        id: String,
        title: String,
        value: String,
        subtitle: String?,
        tileSize: TileSize
    ) {
        self.id = id
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.tileSize = tileSize
    }
}
