import Foundation

public enum L10n {
    private static let bundle = Bundle.module

    public enum Tile {
        public static var feelsLike: String { tr("tile.feels_like.title") }
        public static var humidity: String { tr("tile.humidity.title") }
        public static var wind: String { tr("tile.wind.title") }
        public static var pressure: String { tr("tile.pressure.title") }
        public static var visibility: String { tr("tile.visibility.title") }
        public static var sunrise: String { tr("tile.sunrise.title") }
        public static var airQuality: String { tr("tile.air_quality.title") }
        public static var cloudCover: String { tr("tile.cloud_cover.title") }
        public static var fiveDaySummary: String { tr("tile.five_day_summary.title") }
        public static var precipitation: String { tr("tile.precipitation.title") }
        public static var nextThreeHours: String { tr("tile.precipitation.subtitle") }
    }

    public enum AirQuality {
        public static var good: String { tr("air_quality.good") }
        public static var fair: String { tr("air_quality.fair") }
        public static var moderate: String { tr("air_quality.moderate") }
        public static var poor: String { tr("air_quality.poor") }
        public static var veryPoor: String { tr("air_quality.very_poor") }
        public static var unknown: String { tr("air_quality.unknown") }
    }

    public enum Compass {
        public static let points: [String] = [
            tr("compass.n"), tr("compass.nne"), tr("compass.ne"), tr("compass.ene"),
            tr("compass.e"), tr("compass.ese"), tr("compass.se"), tr("compass.sse"),
            tr("compass.s"), tr("compass.ssw"), tr("compass.sw"), tr("compass.wsw"),
            tr("compass.w"), tr("compass.wnw"), tr("compass.nw"), tr("compass.nnw"),
        ]
    }

    public enum Format {
        public static func temperature(_ value: Int) -> String {
            tr("format.temperature", value)
        }

        public static func feelsLike(_ value: Int) -> String {
            tr("format.feels_like", value)
        }

        public static func percentage(_ value: Int) -> String {
            tr("format.percentage", value)
        }

        public static func windSpeed(_ speed: Double, direction: String) -> String {
            tr("format.wind_speed", speed, direction)
        }

        public static func windSpeedValue(_ speed: Double) -> String {
            tr("format.wind_speed_value", speed)
        }

        public static func pressure(_ value: Int) -> String {
            tr("format.pressure", value)
        }

        public static func visibilityKilometers(_ value: Int) -> String {
            tr("format.visibility_km", value)
        }

        public static func sunsetSubtitle(_ time: String) -> String {
            tr("format.sunset_subtitle", time)
        }

        public static func pm25(_ value: Double) -> String {
            tr("format.pm25", value)
        }

        public static func tempHighLow(high: Int, low: Int) -> String {
            tr("format.temp_high_low", high, low)
        }
    }

    public enum Notice {
        public static var offline: String { tr("notice.offline") }
    }

    private static func tr(_ key: String, _ arguments: CVarArg...) -> String {
        let format = String(localized: String.LocalizationValue(key), bundle: bundle)
        guard !arguments.isEmpty else { return format }
        return String(format: format, locale: Locale.current, arguments: arguments)
    }
}
