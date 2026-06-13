import Foundation

public struct HourlyForecastGrouper {
    public struct ProcessedForecast {
        public let items: [HourlyDisplayItem]
        public let minTemp: Double
        public let maxTemp: Double
    }

    public static func groupByDay(forecast: ForecastResponse) -> [[HourlyForecastItem]] {
        let tzOffset = TimeInterval(forecast.city.timezone)
        let formatter = WeatherFormatters.dayKey(timezoneOffset: tzOffset)
        var groups: [[HourlyForecastItem]] = []
        var currentGroup: [HourlyForecastItem] = []
        var lastDayKey: String?

        for item in forecast.list {
            let dayKey = formatter.string(from: Date(timeIntervalSince1970: item.dt))

            if lastDayKey != dayKey, !currentGroup.isEmpty {
                groups.append(currentGroup)
                currentGroup = []
            }

            currentGroup.append(item)
            lastDayKey = dayKey
        }

        if !currentGroup.isEmpty {
            groups.append(currentGroup)
        }

        return groups
    }

    public static func dayHeaderIndices(from items: [HourlyDisplayItem]) -> [(index: Int, label: String)] {
        items.enumerated().compactMap { index, item in
            guard let label = item.dayLabel else { return nil }
            return (index: index, label: label)
        }
    }

    public static func todayTemperatureRange(
        forecast: ForecastResponse,
        now: Date = Date()
    ) -> (min: Double, max: Double)? {
        temperatureRange(for: forecast, matchingLocalDay: now)
    }

    public static func forecastPeriodTemperatureRange(forecast: ForecastResponse) -> (min: Double, max: Double)? {
        guard !forecast.list.isEmpty else { return nil }
        var minTemp = Double.greatestFiniteMagnitude
        var maxTemp = -Double.greatestFiniteMagnitude
        for item in forecast.list {
            minTemp = min(minTemp, item.main.temp)
            maxTemp = max(maxTemp, item.main.temp)
        }
        return (minTemp, maxTemp)
    }

    public static func temperatureRange(
        for forecast: ForecastResponse,
        matchingLocalDay date: Date
    ) -> (min: Double, max: Double)? {
        let tzOffset = TimeInterval(forecast.city.timezone)
        let formatter = WeatherFormatters.dayKey(timezoneOffset: tzOffset)
        let targetDayKey = formatter.string(from: date)

        let dayItems = groupByDay(forecast: forecast).first { group in
            guard let first = group.first else { return false }
            return formatter.string(from: Date(timeIntervalSince1970: first.dt)) == targetDayKey
        }

        guard let dayItems, !dayItems.isEmpty else { return nil }

        var minTemp = Double.greatestFiniteMagnitude
        var maxTemp = -Double.greatestFiniteMagnitude
        for item in dayItems {
            minTemp = min(minTemp, item.main.temp)
            maxTemp = max(maxTemp, item.main.temp)
        }
        return (minTemp, maxTemp)
    }

    public static func process(forecast: ForecastResponse) -> ProcessedForecast {
        let (minTemp, maxTemp) = paddedTemperatureBounds(for: forecast.list)
        let items = makeDisplayItems(forecast: forecast, minTemp: minTemp, maxTemp: maxTemp)
        return ProcessedForecast(items: items, minTemp: minTemp, maxTemp: maxTemp)
    }

    private static func paddedTemperatureBounds(
        for list: [HourlyForecastItem]
    ) -> (min: Double, max: Double) {
        guard !list.isEmpty else { return (0, 0) }

        var minTemp = Double.greatestFiniteMagnitude
        var maxTemp = -Double.greatestFiniteMagnitude
        for item in list {
            minTemp = min(minTemp, item.main.temp)
            maxTemp = max(maxTemp, item.main.temp)
        }

        if minTemp == maxTemp {
            minTemp -= WeatherConstants.Temperature.flatRangePadding
            maxTemp += WeatherConstants.Temperature.flatRangePadding
        }
        return (minTemp, maxTemp)
    }

    private static func makeDisplayItems(
        forecast: ForecastResponse,
        minTemp: Double,
        maxTemp: Double
    ) -> [HourlyDisplayItem] {
        let tzOffset = TimeInterval(forecast.city.timezone)
        let now = Date().timeIntervalSince1970
        let dayHeaderFormatter = WeatherFormatters.dayHeader(timezoneOffset: tzOffset)
        let timeFormatter = WeatherFormatters.time(timezoneOffset: tzOffset)
        var lastDayString: String?

        return forecast.list.map { item in
            let localDate = Date(timeIntervalSince1970: item.dt)
            let dayString = dayHeaderFormatter.string(from: localDate)
            let dayLabel = lastDayString != dayString ? dayString : nil
            lastDayString = dayString

            let normalisedY = TemperatureGraphGeometry.normalizedDotY(
                temperature: item.main.temp,
                minTemp: minTemp,
                maxTemp: maxTemp
            )
            let pop = item.pop ?? 0
            let popString = pop > 0 ? L10n.Format.percentage(Int(pop * 100)) : nil

            return HourlyDisplayItem(
                time: timeFormatter.string(from: localDate),
                temperature: L10n.Format.temperature(Int(round(item.main.temp))),
                iconURL: WeatherIconURL.make(iconID: item.weather.first?.icon),
                temperatureDotY: normalisedY,
                isCurrentHour: abs(item.dt - now) < WeatherConstants.Forecast.currentSlotTolerance,
                dayLabel: dayLabel,
                precipitationChance: popString
            )
        }
    }
}
