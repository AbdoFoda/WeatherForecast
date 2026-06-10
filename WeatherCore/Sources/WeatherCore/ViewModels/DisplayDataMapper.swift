import Foundation

public struct DisplayDataMapper {
    public static func map(
        weather: CurrentWeatherResponse,
        forecast: ForecastResponse,
        airPollution: AirPollutionResponse
    ) -> LocationWeatherDisplayData {
        let (hourlyItems, _, _) = HourlyForecastGrouper.process(forecast: forecast)
        let todayRange = HourlyForecastGrouper.todayTemperatureRange(forecast: forecast)
        let periodRange = HourlyForecastGrouper.forecastPeriodTemperatureRange(forecast: forecast)

        let tzOffset = TimeInterval(weather.timezone)
        let timeFormatter = WeatherFormatters.time(timezoneOffset: tzOffset)

        let sunriseDate = Date(timeIntervalSince1970: weather.sys.sunrise ?? 0).addingTimeInterval(tzOffset)
        let sunsetDate = Date(timeIntervalSince1970: weather.sys.sunset ?? 0).addingTimeInterval(tzOffset)

        let aqiValue = airPollution.list.first?.main.aqi ?? AirQualityIndex.good.rawValue
        let aqiLabel = AirQualityIndex.label(for: aqiValue)
        let pm25Value = airPollution.list.first?.components.pm2_5 ?? 0

        let windDeg = weather.wind?.deg ?? 0
        let windSpeed = weather.wind?.speed ?? 0
        let windDir = WeatherFormatters.compassDirection(from: Double(windDeg))
        let visibilityKm = (weather.visibility ?? 0) / WeatherConstants.Visibility.metersPerKilometer

        var tiles: [TileDisplayItem] = []

        tiles.append(
            TileDisplayItem(
                id: TileKind.feelsLike.rawValue,
                title: L10n.Tile.feelsLike,
                value: L10n.Format.temperature(Int(round(weather.main.feelsLike))),
                subtitle: nil,
                tileSize: .standard
            )
        )
        tiles.append(
            TileDisplayItem(
                id: TileKind.humidity.rawValue,
                title: L10n.Tile.humidity,
                value: L10n.Format.percentage(weather.main.humidity),
                subtitle: nil,
                tileSize: .standard
            )
        )
        tiles.append(
            TileDisplayItem(
                id: TileKind.wind.rawValue,
                title: L10n.Tile.wind,
                value: L10n.Format.windSpeedValue(windSpeed),
                subtitle: windDir,
                tileSize: .standard
            )
        )
        tiles.append(
            TileDisplayItem(
                id: TileKind.pressure.rawValue,
                title: L10n.Tile.pressure,
                value: L10n.Format.pressure(weather.main.pressure),
                subtitle: nil,
                tileSize: .standard
            )
        )
        tiles.append(
            TileDisplayItem(
                id: TileKind.visibility.rawValue,
                title: L10n.Tile.visibility,
                value: L10n.Format.visibilityKilometers(visibilityKm),
                subtitle: nil,
                tileSize: .standard
            )
        )
        tiles.append(
            TileDisplayItem(
                id: TileKind.sun.rawValue,
                title: L10n.Tile.sunrise,
                value: timeFormatter.string(from: sunriseDate),
                subtitle: L10n.Format.sunsetSubtitle(timeFormatter.string(from: sunsetDate)),
                tileSize: .standard
            )
        )
        tiles.append(
            TileDisplayItem(
                id: TileKind.air.rawValue,
                title: L10n.Tile.airQuality,
                value: aqiLabel,
                subtitle: L10n.Format.pm25(pm25Value),
                tileSize: .wide
            )
        )
        tiles.append(
            TileDisplayItem(
                id: TileKind.clouds.rawValue,
                title: L10n.Tile.cloudCover,
                value: L10n.Format.percentage(weather.clouds?.all ?? 0),
                subtitle: nil,
                tileSize: .standard
            )
        )

        if let periodRange {
            tiles.append(
                TileDisplayItem(
                    id: TileKind.fiveDay.rawValue,
                    title: L10n.Tile.fiveDaySummary,
                    value: L10n.Format.tempHighLow(
                        high: Int(round(periodRange.max)),
                        low: Int(round(periodRange.min))
                    ),
                    subtitle: nil,
                    tileSize: .wide
                )
            )
        }

        if let firstPop = forecast.list.first?.pop {
            tiles.append(
                TileDisplayItem(
                    id: TileKind.precipitation.rawValue,
                    title: L10n.Tile.precipitation,
                    value: L10n.Format.percentage(Int(firstPop * 100)),
                    subtitle: L10n.Tile.nextThreeHours,
                    tileSize: .standard
                )
            )
        }

        let iconURL = WeatherIconURL.make(iconID: weather.weather.first?.icon)

        let tempRange: String = {
            if let todayRange {
                return L10n.Format.tempHighLow(
                    high: Int(round(todayRange.max)),
                    low: Int(round(todayRange.min))
                )
            }
            return L10n.Format.tempHighLow(
                high: Int(round(weather.main.tempMax)),
                low: Int(round(weather.main.tempMin))
            )
        }()

        let cloudCoveragePercent = weather.clouds?.all ?? 0

        return LocationWeatherDisplayData(
            cityName: weather.name,
            countryCode: weather.sys.country ?? "",
            currentTemperature: L10n.Format.temperature(Int(round(weather.main.temp))),
            feelsLike: L10n.Format.feelsLike(Int(round(weather.main.feelsLike))),
            tempRange: tempRange,
            weatherDescription: (weather.weather.first?.description ?? "").capitalized,
            iconURL: iconURL,
            humidity: L10n.Format.percentage(weather.main.humidity),
            pressure: L10n.Format.pressure(weather.main.pressure),
            windSpeed: L10n.Format.windSpeed(windSpeed, direction: windDir),
            visibility: L10n.Format.visibilityKilometers(visibilityKm),
            sunrise: timeFormatter.string(from: sunriseDate),
            sunset: timeFormatter.string(from: sunsetDate),
            aqi: aqiLabel,
            pm25: L10n.Format.pm25(pm25Value),
            cloudCoverage: L10n.Format.percentage(cloudCoveragePercent),
            backgroundScene: WeatherSceneResolver.resolve(from: weather),
            cloudCoveragePercent: cloudCoveragePercent,
            windSpeedMetersPerSecond: windSpeed,
            hourlyItems: hourlyItems,
            tiles: tiles
        )
    }
}
