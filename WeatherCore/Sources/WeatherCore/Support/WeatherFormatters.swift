import Foundation

enum WeatherFormatters {
    static func time(timezoneOffset: TimeInterval) -> DateFormatter {
        formatter(format: WeatherConstants.DateFormat.time, timezoneOffset: timezoneOffset)
    }

    static func dayKey(timezoneOffset: TimeInterval) -> DateFormatter {
        formatter(format: WeatherConstants.DateFormat.dayKey, timezoneOffset: timezoneOffset)
    }

    static func dayHeader(timezoneOffset: TimeInterval) -> DateFormatter {
        formatter(format: WeatherConstants.DateFormat.dayHeader, timezoneOffset: timezoneOffset)
    }

    private static func formatter(format: String, timezoneOffset: TimeInterval) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: Int(timezoneOffset)) ?? TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = format
        return formatter
    }

    static func compassDirection(from degrees: Double) -> String {
        let index = Int((degrees / WeatherConstants.Wind.degreesPerCompassPoint) + 0.5)
            % WeatherConstants.Wind.compassPointCount
        return L10n.Compass.points[index]
    }
}
