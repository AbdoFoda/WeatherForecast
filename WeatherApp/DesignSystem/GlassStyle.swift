import UIKit

enum GlassStyle {
    static let panelBlur: UIBlurEffect.Style = .systemThinMaterialDark
    static let cardBlur: UIBlurEffect.Style = .systemUltraThinMaterial

    @MainActor static var accent: UIColor { ThemeManager.shared.palette.accent }
    @MainActor static var borderColor: UIColor { ThemeManager.shared.palette.borderColor }
    @MainActor static var selectedBorderColor: UIColor { ThemeManager.shared.palette.selectedBorderColor }

    static let textPrimary = UIColor.white
    static let textSecondary = UIColor.white.withAlphaComponent(0.72)

    static func makeBlurView(_ style: UIBlurEffect.Style = panelBlur) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: style))
        view.isUserInteractionEnabled = false
        return view
    }

    @MainActor
    static func applyHairline(to layer: CALayer, radius: CGFloat, selected: Bool = false) {
        layer.cornerRadius = radius
        layer.cornerCurve = .continuous
        layer.borderWidth = selected
            ? WeatherDesignSystem.Glass.selectedHairlineWidth
            : WeatherDesignSystem.Glass.hairlineWidth
        layer.borderColor = (selected ? selectedBorderColor : borderColor).cgColor
    }

    @MainActor
    static func applyMagicGlow(to layer: CALayer) {
        layer.shadowColor = ThemeManager.shared.palette.glowColor.cgColor
        layer.shadowOpacity = WeatherDesignSystem.Glass.glowOpacity
        layer.shadowOffset = .zero
        layer.shadowRadius = WeatherDesignSystem.Glass.glowRadius
    }
}
