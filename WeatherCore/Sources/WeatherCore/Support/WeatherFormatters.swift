import Foundation

enum WeatherFormatters {
    static func time(timezoneOffset: TimeInterval) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = WeatherConstants.DateFormat.time
        return formatter
    }

    static func dayKey(timezoneOffset: TimeInterval) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = WeatherConstants.DateFormat.dayKey
        return formatter
    }

    static func dayHeader(timezoneOffset: TimeInterval) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = WeatherConstants.DateFormat.dayHeader
        return formatter
    }

    static func compassDirection(from degrees: Double) -> String {
        let index = Int((degrees / WeatherConstants.Wind.degreesPerCompassPoint) + 0.5)
            % WeatherConstants.Wind.compassPointCount
        return L10n.Compass.points[index]
    }
}
