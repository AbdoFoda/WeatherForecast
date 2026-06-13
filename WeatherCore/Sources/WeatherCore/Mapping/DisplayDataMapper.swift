import Foundation

public struct DisplayDataMapper {
    public static func map(
        weather: CurrentWeatherResponse,
        forecast: ForecastResponse,
        airPollution: AirPollutionResponse,
        tileOrder: [TileKind] = TileKind.allCases
    ) -> LocationWeatherDisplayData {
        let metrics = Metrics(weather: weather, forecast: forecast, airPollution: airPollution)
        let tiles = makeTiles(weather: weather, forecast: forecast, metrics: metrics)
        let orderedTiles = TileOrderApplier.apply(order: tileOrder, to: tiles)
        return makeDisplayData(weather: weather, forecast: forecast, metrics: metrics, tiles: orderedTiles)
    }

    public static func mapOffMainThread(
        weather: CurrentWeatherResponse,
        forecast: ForecastResponse,
        airPollution: AirPollutionResponse,
        tileOrder: [TileKind] = TileKind.allCases
    ) async -> LocationWeatherDisplayData {
        await Task.detached(priority: .userInitiated) {
            map(weather: weather, forecast: forecast, airPollution: airPollution, tileOrder: tileOrder)
        }.value
    }

    private struct Metrics {
        let timeFormatter: DateFormatter
        let sunriseDate: Date
        let sunsetDate: Date
        let aqiLabel: String
        let pm25Value: Double
        let windSpeed: Double
        let windDir: String
        let visibilityKm: Int
        let cloudCoveragePercent: Int
        let todayRange: (min: Double, max: Double)?
        let periodRange: (min: Double, max: Double)?
        let hourlyItems: [HourlyDisplayItem]

        init(weather: CurrentWeatherResponse, forecast: ForecastResponse, airPollution: AirPollutionResponse) {
            let tzOffset = TimeInterval(weather.timezone)
            timeFormatter = WeatherFormatters.time(timezoneOffset: tzOffset)
            sunriseDate = Date(timeIntervalSince1970: weather.sys.sunrise ?? 0)
            sunsetDate = Date(timeIntervalSince1970: weather.sys.sunset ?? 0)

            let aqiValue = airPollution.list.first?.main.aqi ?? AirQualityIndex.good.rawValue
            aqiLabel = AirQualityIndex.label(for: aqiValue)
            pm25Value = airPollution.list.first?.components.pm2_5 ?? 0

            windSpeed = weather.wind?.speed ?? 0
            windDir = WeatherFormatters.compassDirection(from: Double(weather.wind?.deg ?? 0))
            visibilityKm = (weather.visibility ?? 0) / WeatherConstants.Visibility.metersPerKilometer
            cloudCoveragePercent = weather.clouds?.all ?? 0

            todayRange = HourlyForecastGrouper.todayTemperatureRange(forecast: forecast)
            periodRange = HourlyForecastGrouper.forecastPeriodTemperatureRange(forecast: forecast)
            hourlyItems = HourlyForecastGrouper.process(forecast: forecast).items
        }
    }

    private static func tile(
        _ kind: TileKind,
        title: String,
        value: String,
        subtitle: String? = nil,
        size: TileDisplayItem.TileSize = .standard
    ) -> TileDisplayItem {
        TileDisplayItem(id: kind.rawValue, title: title, value: value, subtitle: subtitle, tileSize: size)
    }

    private static func makeTiles(
        weather: CurrentWeatherResponse,
        forecast: ForecastResponse,
        metrics: Metrics
    ) -> [TileDisplayItem] {
        let sunset = L10n.Format.sunsetSubtitle(metrics.timeFormatter.string(from: metrics.sunsetDate))
        var tiles: [TileDisplayItem] = [
            tile(.feelsLike, title: L10n.Tile.feelsLike,
                 value: L10n.Format.temperature(Int(round(weather.main.feelsLike)))),
            tile(.humidity, title: L10n.Tile.humidity,
                 value: L10n.Format.percentage(weather.main.humidity)),
            tile(.wind, title: L10n.Tile.wind,
                 value: L10n.Format.windSpeedValue(metrics.windSpeed), subtitle: metrics.windDir),
            tile(.pressure, title: L10n.Tile.pressure,
                 value: L10n.Format.pressure(weather.main.pressure)),
            tile(.visibility, title: L10n.Tile.visibility,
                 value: L10n.Format.visibilityKilometers(metrics.visibilityKm)),
            tile(.sun, title: L10n.Tile.sunrise,
                 value: metrics.timeFormatter.string(from: metrics.sunriseDate), subtitle: sunset),
            tile(.air, title: L10n.Tile.airQuality,
                 value: metrics.aqiLabel, subtitle: L10n.Format.pm25(metrics.pm25Value), size: .wide),
            tile(.clouds, title: L10n.Tile.cloudCover,
                 value: L10n.Format.percentage(metrics.cloudCoveragePercent))
        ]

        if let periodRange = metrics.periodRange {
            let value = L10n.Format.tempHighLow(high: Int(round(periodRange.max)), low: Int(round(periodRange.min)))
            tiles.append(tile(.fiveDay, title: L10n.Tile.fiveDaySummary, value: value, size: .wide))
        }

        if let firstPop = forecast.list.first?.pop {
            tiles.append(
                tile(.precipitation, title: L10n.Tile.precipitation,
                     value: L10n.Format.percentage(Int(firstPop * 100)), subtitle: L10n.Tile.nextThreeHours)
            )
        }

        return tiles
    }

    private static func resolveTempRange(weather: CurrentWeatherResponse, metrics: Metrics) -> String {
        if let todayRange = metrics.todayRange,
           Int(round(todayRange.max)) != Int(round(todayRange.min)) {
            return L10n.Format.tempHighLow(high: Int(round(todayRange.max)), low: Int(round(todayRange.min)))
        }
        if let periodRange = metrics.periodRange {
            return L10n.Format.tempHighLow(high: Int(round(periodRange.max)), low: Int(round(periodRange.min)))
        }
        return L10n.Format.tempHighLow(high: Int(round(weather.main.tempMax)), low: Int(round(weather.main.tempMin)))
    }

    private static func makeDisplayData(
        weather: CurrentWeatherResponse,
        forecast: ForecastResponse,
        metrics: Metrics,
        tiles: [TileDisplayItem]
    ) -> LocationWeatherDisplayData {
        LocationWeatherDisplayData(
            cityName: weather.name,
            countryCode: weather.sys.country ?? "",
            currentTemperature: L10n.Format.temperature(Int(round(weather.main.temp))),
            feelsLike: L10n.Format.feelsLike(Int(round(weather.main.feelsLike))),
            tempRange: resolveTempRange(weather: weather, metrics: metrics),
            weatherDescription: (weather.weather.first?.description ?? "").capitalized,
            iconURL: WeatherIconURL.make(iconID: weather.weather.first?.icon),
            humidity: L10n.Format.percentage(weather.main.humidity),
            pressure: L10n.Format.pressure(weather.main.pressure),
            windSpeed: L10n.Format.windSpeed(metrics.windSpeed, direction: metrics.windDir),
            visibility: L10n.Format.visibilityKilometers(metrics.visibilityKm),
            sunrise: metrics.timeFormatter.string(from: metrics.sunriseDate),
            sunset: metrics.timeFormatter.string(from: metrics.sunsetDate),
            aqi: metrics.aqiLabel,
            pm25: L10n.Format.pm25(metrics.pm25Value),
            cloudCoverage: L10n.Format.percentage(metrics.cloudCoveragePercent),
            backgroundScene: WeatherSceneResolver.resolve(from: weather),
            cloudCoveragePercent: metrics.cloudCoveragePercent,
            windSpeedMetersPerSecond: metrics.windSpeed,
            hourlyItems: metrics.hourlyItems,
            tiles: tiles
        )
    }
}
