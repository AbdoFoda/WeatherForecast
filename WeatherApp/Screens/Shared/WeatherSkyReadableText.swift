import UIKit

enum WeatherSkyReadableText {
    static func applyPrimary(to label: UILabel) {
        label.textColor = WeatherDesignSystem.SkyText.primaryColor
        applyShadow(to: label, opacity: WeatherDesignSystem.SkyText.primaryShadowOpacity)
    }

    static func applySecondary(to label: UILabel) {
        label.textColor = WeatherDesignSystem.SkyText.primaryColor.withAlphaComponent(
            WeatherDesignSystem.SkyText.secondaryAlpha
        )
        applyShadow(to: label, opacity: WeatherDesignSystem.SkyText.secondaryShadowOpacity)
    }

    private static func applyShadow(to label: UILabel, opacity: Float) {
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOffset = WeatherDesignSystem.SkyText.shadowOffset
        label.layer.shadowOpacity = opacity
        label.layer.shadowRadius = WeatherDesignSystem.SkyText.shadowRadius
        label.layer.masksToBounds = false
    }
}
