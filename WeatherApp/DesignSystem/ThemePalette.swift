import UIKit
import WeatherCore

struct ThemePalette {
    let theme: AppTheme
    let displayName: String

    let accent: UIColor
    let secondary: UIColor

    let tintTop: UIColor
    let tintBottom: UIColor

    var borderColor: UIColor { accent.withAlphaComponent(0.45) }
    var selectedBorderColor: UIColor { secondary.withAlphaComponent(0.95) }
    var glowColor: UIColor { accent }
    var curveColor: UIColor { secondary }

    var listBackgroundTop: UIColor { accent.mixed(with: .white, amount: 0.90) }
    var listBackgroundBottom: UIColor { accent.mixed(with: .white, amount: 0.76) }

    var cardTintTop: UIColor { accent }
    var cardTintBottom: UIColor { secondary }

    var swatch: [UIColor] { [accent, secondary] }
}

extension UIColor {
    func mixed(with other: UIColor, amount: CGFloat) -> UIColor {
        var red1: CGFloat = 0, green1: CGFloat = 0, blue1: CGFloat = 0, alpha1: CGFloat = 0
        var red2: CGFloat = 0, green2: CGFloat = 0, blue2: CGFloat = 0, alpha2: CGFloat = 0
        getRed(&red1, green: &green1, blue: &blue1, alpha: &alpha1)
        other.getRed(&red2, green: &green2, blue: &blue2, alpha: &alpha2)
        let blend = max(0, min(1, amount))
        return UIColor(
            red: red1 + (red2 - red1) * blend,
            green: green1 + (green2 - green1) * blend,
            blue: blue1 + (blue2 - blue1) * blend,
            alpha: alpha1 + (alpha2 - alpha1) * blend
        )
    }
}

extension ThemePalette {
    static func palette(for theme: AppTheme) -> ThemePalette {
        switch theme {
        case .magic:
            return ThemePalette(
                theme: .magic,
                displayName: AppL10n.themeMagic,
                accent: rgb(0.62, 0.18, 0.92),
                secondary: rgb(0.20, 0.84, 0.94),
                tintTop: rgb(0.46, 0.16, 0.78),
                tintBottom: rgb(0.20, 0.10, 0.42)
            )
        case .ocean:
            return ThemePalette(
                theme: .ocean,
                displayName: AppL10n.themeOcean,
                accent: rgb(0.12, 0.58, 0.96),
                secondary: rgb(0.24, 0.95, 0.86),
                tintTop: rgb(0.10, 0.42, 0.74),
                tintBottom: rgb(0.06, 0.20, 0.40)
            )
        case .sunset:
            return ThemePalette(
                theme: .sunset,
                displayName: AppL10n.themeSunset,
                accent: rgb(1.0, 0.46, 0.30),
                secondary: rgb(1.0, 0.80, 0.34),
                tintTop: rgb(0.86, 0.30, 0.42),
                tintBottom: rgb(0.40, 0.14, 0.36)
            )
        case .forest:
            return ThemePalette(
                theme: .forest,
                displayName: AppL10n.themeForest,
                accent: rgb(0.22, 0.78, 0.48),
                secondary: rgb(0.78, 0.94, 0.40),
                tintTop: rgb(0.14, 0.50, 0.40),
                tintBottom: rgb(0.06, 0.24, 0.24)
            )
        case .midnight:
            return ThemePalette(
                theme: .midnight,
                displayName: AppL10n.themeMidnight,
                accent: rgb(0.62, 0.67, 0.80),
                secondary: rgb(0.90, 0.93, 0.98),
                tintTop: rgb(0.22, 0.25, 0.34),
                tintBottom: rgb(0.08, 0.10, 0.16)
            )
        }
    }

    private static func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> UIColor {
        UIColor(red: r, green: g, blue: b, alpha: 1)
    }
}
