import UIKit
import WeatherCore

enum WeatherBackgroundPalette {
    struct GradientColors {
        let top: UIColor
        let bottom: UIColor
    }

    private enum Token {
        static let neutralTop = UIColor(red: 0.75, green: 0.78, blue: 0.84, alpha: 1)
        static let neutralBottom = UIColor(red: 0.90, green: 0.91, blue: 0.93, alpha: 1)
        static let clearDayTop = UIColor(red: 0.25, green: 0.58, blue: 0.95, alpha: 1)
        static let clearDayBottom = UIColor(red: 0.55, green: 0.78, blue: 0.98, alpha: 1)
        static let clearNightTop = UIColor(red: 0.05, green: 0.08, blue: 0.22, alpha: 1)
        static let clearNightBottom = UIColor(red: 0.12, green: 0.16, blue: 0.32, alpha: 1)
        static let partlyCloudyDayTop = UIColor(red: 0.38, green: 0.60, blue: 0.88, alpha: 1)
        static let partlyCloudyDayBottom = UIColor(red: 0.72, green: 0.82, blue: 0.94, alpha: 1)
        static let partlyCloudyNightTop = UIColor(red: 0.10, green: 0.14, blue: 0.28, alpha: 1)
        static let partlyCloudyNightBottom = UIColor(red: 0.20, green: 0.24, blue: 0.38, alpha: 1)
        static let cloudyTop = UIColor(red: 0.45, green: 0.50, blue: 0.56, alpha: 1)
        static let cloudyBottom = UIColor(red: 0.66, green: 0.70, blue: 0.74, alpha: 1)
        static let rainTop = UIColor(red: 0.28, green: 0.34, blue: 0.42, alpha: 1)
        static let rainBottom = UIColor(red: 0.45, green: 0.51, blue: 0.58, alpha: 1)
        static let thunderstormTop = UIColor(red: 0.14, green: 0.16, blue: 0.24, alpha: 1)
        static let thunderstormBottom = UIColor(red: 0.28, green: 0.30, blue: 0.38, alpha: 1)
        static let snowTop = UIColor(red: 0.62, green: 0.70, blue: 0.82, alpha: 1)
        static let snowBottom = UIColor(red: 0.84, green: 0.88, blue: 0.94, alpha: 1)
        static let fogTop = UIColor(red: 0.58, green: 0.62, blue: 0.66, alpha: 1)
        static let fogBottom = UIColor(red: 0.76, green: 0.78, blue: 0.80, alpha: 1)
    }

    static func colors(for scene: WeatherScene) -> GradientColors {
        switch scene {
        case .neutral, .unknown:
            return GradientColors(top: Token.neutralTop, bottom: Token.neutralBottom)
        case .clearDay:
            return GradientColors(top: Token.clearDayTop, bottom: Token.clearDayBottom)
        case .clearNight:
            return GradientColors(top: Token.clearNightTop, bottom: Token.clearNightBottom)
        case .partlyCloudyDay:
            return GradientColors(top: Token.partlyCloudyDayTop, bottom: Token.partlyCloudyDayBottom)
        case .partlyCloudyNight:
            return GradientColors(top: Token.partlyCloudyNightTop, bottom: Token.partlyCloudyNightBottom)
        case .cloudy:
            return GradientColors(top: Token.cloudyTop, bottom: Token.cloudyBottom)
        case .rain, .drizzle:
            return GradientColors(top: Token.rainTop, bottom: Token.rainBottom)
        case .thunderstorm:
            return GradientColors(top: Token.thunderstormTop, bottom: Token.thunderstormBottom)
        case .snow:
            return GradientColors(top: Token.snowTop, bottom: Token.snowBottom)
        case .fog:
            return GradientColors(top: Token.fogTop, bottom: Token.fogBottom)
        }
    }
}
