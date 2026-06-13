import UIKit
import WeatherCore

final class WeatherCelestialGlowView: UIView {
    private let glowLayer = CALayer()
    private let bodyLayer = CALayer()
    private let motionContainer = CALayer()

    private var configuredWindSpeed: Double = 0
    private var allowsAnimation = false
    private var appliedMotionSignature: String?

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        layer.addSublayer(motionContainer)
        motionContainer.addSublayer(glowLayer)
        motionContainer.addSublayer(bodyLayer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        stopMotion()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let diameter = WeatherBackgroundConstants.Celestial.bodyDiameter
        let origin = CGPoint(
            x: bounds.width * WeatherBackgroundConstants.Celestial.horizontalAnchorRatio,
            y: max(
                bounds.height * WeatherBackgroundConstants.Celestial.verticalAnchorRatio,
                WeatherBackgroundConstants.Celestial.minimumVerticalAnchor
            )
        )
        motionContainer.frame = CGRect(origin: origin, size: CGSize(width: diameter, height: diameter))
        bodyLayer.frame = motionContainer.bounds
        glowLayer.frame = motionContainer.bounds.insetBy(
            dx: -WeatherBackgroundConstants.Celestial.glowInset,
            dy: -WeatherBackgroundConstants.Celestial.glowInset
        )
        bodyLayer.cornerRadius = diameter / 2
        glowLayer.cornerRadius = glowLayer.bounds.width / 2
        applyMotionIfNeeded()
    }

    func configure(scene: WeatherScene, windSpeedMetersPerSecond: Double, animated: Bool) {
        configuredWindSpeed = windSpeedMetersPerSecond
        allowsAnimation = animated && !UIAccessibility.isReduceMotionEnabled
        appliedMotionSignature = nil

        switch WeatherBackgroundEffectsPolicy.celestialKind(for: scene) {
        case .none:
            isHidden = true
            stopMotion()
        case .sun:
            isHidden = false
            bodyLayer.backgroundColor = UIColor(
                red: WeatherBackgroundConstants.Celestial.Sun.bodyRed,
                green: WeatherBackgroundConstants.Celestial.Sun.bodyGreen,
                blue: WeatherBackgroundConstants.Celestial.Sun.bodyBlue,
                alpha: 1
            ).cgColor
            glowLayer.backgroundColor = UIColor(
                red: WeatherBackgroundConstants.Celestial.Sun.glowRed,
                green: WeatherBackgroundConstants.Celestial.Sun.glowGreen,
                blue: WeatherBackgroundConstants.Celestial.Sun.glowBlue,
                alpha: WeatherBackgroundConstants.Celestial.Sun.glowAlpha
            ).cgColor
            bodyLayer.shadowOpacity = 0
            applyMotionIfNeeded()
        case .moon:
            isHidden = false
            bodyLayer.backgroundColor = UIColor(
                white: WeatherBackgroundConstants.Celestial.Moon.bodyWhite,
                alpha: 1
            ).cgColor
            glowLayer.backgroundColor = UIColor(
                white: WeatherBackgroundConstants.Celestial.Moon.glowWhite,
                alpha: WeatherBackgroundConstants.Celestial.Moon.glowAlpha
            ).cgColor
            bodyLayer.shadowOpacity = 0
            applyMotionIfNeeded()
        }
    }

    private func applyMotionIfNeeded() {
        guard allowsAnimation, !isHidden else {
            glowLayer.removeAnimation(forKey: WeatherBackgroundConstants.Animation.Key.pulse)
            motionContainer.removeAnimation(forKey: WeatherBackgroundConstants.Animation.Key.sway)
            glowLayer.opacity = 1
            return
        }

        let signature = "\(configuredWindSpeed)"
        guard signature != appliedMotionSignature else { return }
        appliedMotionSignature = signature

        glowLayer.removeAnimation(forKey: WeatherBackgroundConstants.Animation.Key.pulse)
        motionContainer.removeAnimation(forKey: WeatherBackgroundConstants.Animation.Key.sway)

        let pulse = CABasicAnimation(keyPath: "opacity")
        pulse.fromValue = WeatherBackgroundConstants.Animation.pulseOpacityMin
        pulse.toValue = WeatherBackgroundConstants.Animation.pulseOpacityMax
        pulse.duration = WeatherBackgroundConstants.Animation.celestialPulseDuration
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        glowLayer.add(pulse, forKey: WeatherBackgroundConstants.Animation.Key.pulse)

        let swayDistance = WeatherBackgroundMotionPolicy.celestialSwayDistance(windSpeed: configuredWindSpeed)
        let swayDuration = WeatherBackgroundMotionPolicy.celestialSwayDuration(windSpeed: configuredWindSpeed)
        let sway = CABasicAnimation(keyPath: "transform.translation.x")
        sway.fromValue = -swayDistance
        sway.toValue = swayDistance
        sway.duration = swayDuration
        sway.autoreverses = true
        sway.repeatCount = .infinity
        sway.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        motionContainer.add(sway, forKey: WeatherBackgroundConstants.Animation.Key.sway)
    }

    private func stopMotion() {
        allowsAnimation = false
        appliedMotionSignature = nil
        layer.removeAllAnimations()
        motionContainer.removeAllAnimations()
        glowLayer.removeAllAnimations()
        bodyLayer.removeAllAnimations()
    }
}
