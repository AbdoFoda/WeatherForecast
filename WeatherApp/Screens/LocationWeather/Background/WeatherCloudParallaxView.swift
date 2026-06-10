import UIKit
import WeatherCore

final class WeatherCloudParallaxView: UIView {
    private let backCloud = UIImageView()
    private let frontCloud = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        [backCloud, frontCloud].forEach {
            $0.contentMode = .scaleAspectFit
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }
        NSLayoutConstraint.activate([
            backCloud.leadingAnchor.constraint(equalTo: leadingAnchor, constant: -40),
            backCloud.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -30),
            backCloud.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.9),
            backCloud.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.35),

            frontCloud.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 30),
            frontCloud.centerYAnchor.constraint(equalTo: centerYAnchor, constant: 10),
            frontCloud.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.75),
            frontCloud.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.28),
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(scene: WeatherScene, cloudCoveragePercent: Int, animated: Bool) {
        let visible = WeatherBackgroundEffectsPolicy.shouldShowClouds(
            scene: scene,
            cloudCoveragePercent: cloudCoveragePercent
        )
        isHidden = !visible
        guard visible else {
            layer.removeAllAnimations()
            return
        }

        let opacity = min(
            WeatherBackgroundConstants.Cloud.maxOpacity,
            Float(cloudCoveragePercent) / 100 * WeatherBackgroundConstants.Cloud.maxOpacity
        )
        backCloud.alpha = CGFloat(opacity * 0.75)
        frontCloud.alpha = CGFloat(opacity)

        let backImage = WeatherBackgroundAssetFactory.cloudImage(width: 280, height: 120)
        let frontImage = WeatherBackgroundAssetFactory.cloudImage(width: 220, height: 90)
        backCloud.image = backImage
        frontCloud.image = frontImage

        layer.removeAllAnimations()
        backCloud.layer.removeAllAnimations()
        frontCloud.layer.removeAllAnimations()

        guard animated, !UIAccessibility.isReduceMotionEnabled else { return }

        addDrift(to: backCloud.layer, distance: 28, duration: WeatherBackgroundConstants.parallaxDuration)
        addDrift(to: frontCloud.layer, distance: -22, duration: WeatherBackgroundConstants.parallaxDuration * 0.8)
    }

    private func addDrift(to layer: CALayer, distance: CGFloat, duration: TimeInterval) {
        let animation = CABasicAnimation(keyPath: "transform.translation.x")
        animation.fromValue = 0
        animation.toValue = distance
        animation.duration = duration
        animation.autoreverses = true
        animation.repeatCount = .infinity
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        layer.add(animation, forKey: "drift")
    }
}
