import UIKit
import WeatherCore

enum WeatherBackgroundPalette {
    struct GradientColors {
        let top: UIColor
        let bottom: UIColor
    }

    static func colors(for scene: WeatherScene) -> GradientColors {
        switch scene {
        case .neutral, .unknown:
            return GradientColors(
                top: UIColor(red: 0.75, green: 0.78, blue: 0.84, alpha: 1),
                bottom: UIColor(red: 0.90, green: 0.91, blue: 0.93, alpha: 1)
            )
        case .clearDay:
            return GradientColors(
                top: UIColor(red: 0.25, green: 0.58, blue: 0.95, alpha: 1),
                bottom: UIColor(red: 0.55, green: 0.78, blue: 0.98, alpha: 1)
            )
        case .clearNight:
            return GradientColors(
                top: UIColor(red: 0.05, green: 0.08, blue: 0.22, alpha: 1),
                bottom: UIColor(red: 0.12, green: 0.16, blue: 0.32, alpha: 1)
            )
        case .partlyCloudyDay:
            return GradientColors(
                top: UIColor(red: 0.38, green: 0.60, blue: 0.88, alpha: 1),
                bottom: UIColor(red: 0.72, green: 0.82, blue: 0.94, alpha: 1)
            )
        case .partlyCloudyNight:
            return GradientColors(
                top: UIColor(red: 0.10, green: 0.14, blue: 0.28, alpha: 1),
                bottom: UIColor(red: 0.20, green: 0.24, blue: 0.38, alpha: 1)
            )
        case .cloudy:
            return GradientColors(
                top: UIColor(red: 0.45, green: 0.50, blue: 0.56, alpha: 1),
                bottom: UIColor(red: 0.66, green: 0.70, blue: 0.74, alpha: 1)
            )
        case .rain, .drizzle:
            return GradientColors(
                top: UIColor(red: 0.28, green: 0.34, blue: 0.42, alpha: 1),
                bottom: UIColor(red: 0.45, green: 0.51, blue: 0.58, alpha: 1)
            )
        case .thunderstorm:
            return GradientColors(
                top: UIColor(red: 0.14, green: 0.16, blue: 0.24, alpha: 1),
                bottom: UIColor(red: 0.28, green: 0.30, blue: 0.38, alpha: 1)
            )
        case .snow:
            return GradientColors(
                top: UIColor(red: 0.62, green: 0.70, blue: 0.82, alpha: 1),
                bottom: UIColor(red: 0.84, green: 0.88, blue: 0.94, alpha: 1)
            )
        case .fog:
            return GradientColors(
                top: UIColor(red: 0.58, green: 0.62, blue: 0.66, alpha: 1),
                bottom: UIColor(red: 0.76, green: 0.78, blue: 0.80, alpha: 1)
            )
        }
    }
}
