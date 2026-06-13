import UIKit

enum GlassStyle {
    static let panelBlur: UIBlurEffect.Style = .systemThinMaterialDark
    static let cardBlur: UIBlurEffect.Style = .systemUltraThinMaterial

    static let borderColor = UIColor.white.withAlphaComponent(0.14)
    static let selectedBorderColor = UIColor.white.withAlphaComponent(0.92)

    static let textPrimary = UIColor.white
    static let textSecondary = UIColor.white.withAlphaComponent(0.72)

    static func makeBlurView(_ style: UIBlurEffect.Style = panelBlur) -> UIVisualEffectView {
        let view = UIVisualEffectView(effect: UIBlurEffect(style: style))
        view.isUserInteractionEnabled = false
        return view
    }

    static func applyHairline(to layer: CALayer, radius: CGFloat, selected: Bool = false) {
        layer.cornerRadius = radius
        layer.cornerCurve = .continuous
        layer.borderWidth = selected ? 2 : 1
        layer.borderColor = (selected ? selectedBorderColor : borderColor).cgColor
    }
}
