import UIKit
import WeatherCore

final class WeatherCelestialGlowView: UIView {
    private let glowLayer = CALayer()
    private let bodyLayer = CALayer()

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        layer.addSublayer(glowLayer)
        layer.addSublayer(bodyLayer)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let diameter: CGFloat = 56
        let origin = CGPoint(x: bounds.width * 0.72, y: bounds.height * 0.14)
        let frame = CGRect(origin: origin, size: CGSize(width: diameter, height: diameter))
        bodyLayer.frame = frame
        glowLayer.frame = frame.insetBy(dx: -18, dy: -18)
        bodyLayer.cornerRadius = diameter / 2
        glowLayer.cornerRadius = glowLayer.bounds.width / 2
    }

    func configure(scene: WeatherScene, animated: Bool) {
        switch WeatherBackgroundEffectsPolicy.celestialKind(for: scene) {
        case .none:
            isHidden = true
            layer.removeAllAnimations()
        case .sun:
            isHidden = false
            bodyLayer.backgroundColor = UIColor(red: 1, green: 0.92, blue: 0.45, alpha: 1).cgColor
            glowLayer.backgroundColor = UIColor(red: 1, green: 0.85, blue: 0.35, alpha: 0.35).cgColor
            bodyLayer.shadowOpacity = 0
            animatePulse(enabled: animated)
        case .moon:
            isHidden = false
            bodyLayer.backgroundColor = UIColor(white: 0.92, alpha: 1).cgColor
            glowLayer.backgroundColor = UIColor(white: 0.85, alpha: 0.22).cgColor
            bodyLayer.shadowOpacity = 0
            animatePulse(enabled: animated)
        }
    }

    private func animatePulse(enabled: Bool) {
        glowLayer.removeAllAnimations()
        guard enabled, !UIAccessibility.isReduceMotionEnabled else {
            glowLayer.opacity = 1
            return
        }
        let pulse = CABasicAnimation(keyPath: "opacity")
        pulse.fromValue = 0.65
        pulse.toValue = 1
        pulse.duration = WeatherBackgroundConstants.celestialPulseDuration
        pulse.autoreverses = true
        pulse.repeatCount = .infinity
        glowLayer.add(pulse, forKey: "pulse")
    }
}
