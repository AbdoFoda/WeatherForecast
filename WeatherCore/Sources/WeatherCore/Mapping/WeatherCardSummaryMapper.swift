import Foundation

public enum WeatherCardSummaryMapper {
    public static func map(weather: CurrentWeatherResponse) -> LocationCardSummary {
        let tzOffset = TimeInterval(weather.timezone)
        let localDate = Date(timeIntervalSince1970: weather.dt).addingTimeInterval(tzOffset)
        let localTime = WeatherFormatters.time(timezoneOffset: tzOffset).string(from: localDate)

        return LocationCardSummary(
            temperature: L10n.Format.temperature(Int(round(weather.main.temp))),
            conditionText: (weather.weather.first?.description ?? "").capitalized,
            highLow: L10n.Format.tempHighLow(
                high: Int(round(weather.main.tempMax)),
                low: Int(round(weather.main.tempMin))
            ),
            localTime: localTime,
            scene: WeatherSceneResolver.resolve(from: weather)
        )
    }
}
