import UIKit

enum WeatherSkyReadableText {
    static func applyPrimary(to label: UILabel) {
        label.textColor = .white
        applyShadow(to: label, opacity: 0.45)
    }

    static func applySecondary(to label: UILabel) {
        label.textColor = UIColor.white.withAlphaComponent(0.92)
        applyShadow(to: label, opacity: 0.35)
    }

    private static func applyShadow(to label: UILabel, opacity: Float) {
        label.layer.shadowColor = UIColor.black.cgColor
        label.layer.shadowOffset = CGSize(width: 0, height: 1)
        label.layer.shadowOpacity = opacity
        label.layer.shadowRadius = 4
        label.layer.masksToBounds = false
    }
}
