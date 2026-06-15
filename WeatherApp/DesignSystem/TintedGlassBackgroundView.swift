import UIKit

final class TintedGlassBackgroundView: UIView {
    private let blurView = GlassStyle.makeBlurView(GlassStyle.cardBlur)
    private let tintView = GradientView()
    private let fixedCornerRadius: CGFloat
    private let isCapsule: Bool
    private let showsBorder: Bool

    init(cornerRadius: CGFloat = 0, capsule: Bool = false, showsBorder: Bool = false) {
        self.fixedCornerRadius = cornerRadius
        self.isCapsule = capsule
        self.showsBorder = showsBorder
        super.init(frame: .zero)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        isUserInteractionEnabled = false
        layer.cornerRadius = fixedCornerRadius
        layer.cornerCurve = .continuous
        clipsToBounds = true

        blurView.frame = bounds
        blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        addSubview(blurView)

        tintView.frame = bounds
        tintView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        tintView.gradientLayer.startPoint = CGPoint(x: 0.5, y: 0)
        tintView.gradientLayer.endPoint = CGPoint(x: 0.5, y: 1)
        addSubview(tintView)

        applyTheme()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applyTheme),
            name: .themeDidChange,
            object: nil
        )
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if isCapsule {
            layer.cornerRadius = min(bounds.width, bounds.height) / 2
        }
    }

    @objc private func applyTheme() {
        let palette = ThemeManager.shared.palette
        tintView.gradientLayer.colors = [
            palette.tintTop.withAlphaComponent(WeatherDesignSystem.Glass.panelTintTopAlpha).cgColor,
            palette.tintBottom.withAlphaComponent(WeatherDesignSystem.Glass.panelTintBottomAlpha).cgColor
        ]
        if showsBorder {
            layer.borderWidth = WeatherDesignSystem.Glass.hairlineWidth
            layer.borderColor = GlassStyle.borderColor.cgColor
        }
    }
}

final class GradientView: UIView {
    override static var layerClass: AnyClass { CAGradientLayer.self }

    var gradientLayer: CAGradientLayer {
        guard let gradient = layer as? CAGradientLayer else {
            preconditionFailure("GradientView.layer must be a CAGradientLayer")
        }
        return gradient
    }
}
