import CoreGraphics
import Foundation

public struct LocationWeatherDisplayData: Sendable, Codable {
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
    public let postalCode: String?
    public let altitude: String?

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
        tiles: [TileDisplayItem],
        postalCode: String? = nil,
        altitude: String? = nil
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
        self.postalCode = postalCode
        self.altitude = altitude
    }

    public func withTiles(_ tiles: [TileDisplayItem]) -> LocationWeatherDisplayData {
        copy(tiles: tiles)
    }

    public func mergingLocationDetails(postalCode: String?, altitude: String?) -> LocationWeatherDisplayData {
        LocationWeatherDisplayData(
            cityName: cityName,
            countryCode: countryCode,
            currentTemperature: currentTemperature,
            feelsLike: feelsLike,
            tempRange: tempRange,
            weatherDescription: weatherDescription,
            iconURL: iconURL,
            humidity: humidity,
            pressure: pressure,
            windSpeed: windSpeed,
            visibility: visibility,
            sunrise: sunrise,
            sunset: sunset,
            aqi: aqi,
            pm25: pm25,
            cloudCoverage: cloudCoverage,
            backgroundScene: backgroundScene,
            cloudCoveragePercent: cloudCoveragePercent,
            windSpeedMetersPerSecond: windSpeedMetersPerSecond,
            hourlyItems: hourlyItems,
            tiles: tiles,
            postalCode: postalCode ?? self.postalCode,
            altitude: altitude ?? self.altitude
        )
    }

    private func copy(tiles: [TileDisplayItem]? = nil) -> LocationWeatherDisplayData {
        LocationWeatherDisplayData(
            cityName: cityName,
            countryCode: countryCode,
            currentTemperature: currentTemperature,
            feelsLike: feelsLike,
            tempRange: tempRange,
            weatherDescription: weatherDescription,
            iconURL: iconURL,
            humidity: humidity,
            pressure: pressure,
            windSpeed: windSpeed,
            visibility: visibility,
            sunrise: sunrise,
            sunset: sunset,
            aqi: aqi,
            pm25: pm25,
            cloudCoverage: cloudCoverage,
            backgroundScene: backgroundScene,
            cloudCoveragePercent: cloudCoveragePercent,
            windSpeedMetersPerSecond: windSpeedMetersPerSecond,
            hourlyItems: hourlyItems,
            tiles: tiles ?? self.tiles,
            postalCode: postalCode,
            altitude: altitude
        )
    }
}
