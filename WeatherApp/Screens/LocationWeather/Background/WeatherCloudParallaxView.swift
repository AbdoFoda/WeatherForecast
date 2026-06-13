import UIKit
import WeatherCore

final class WeatherCloudParallaxView: UIView {
    private let backBand = UIImageView()
    private let frontBand = UIImageView()

    private var configuredScene: WeatherScene = .neutral
    private var configuredCoverage = 0
    private var configuredWindSpeed: Double = 0
    private var configuredOpacity: CGFloat = 0
    private var allowsAnimation = false
    private var lastRenderedSize: CGSize = .zero
    private var lastLayoutSize: CGSize = .zero
    private var appliedMotionSignature: String?

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        clipsToBounds = true
        [backBand, frontBand].forEach {
            $0.contentMode = .scaleToFill
            $0.clipsToBounds = true
            addSubview($0)
        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        stopMotion()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutBands()
        refreshTexturesIfNeeded()
    }

    func configure(
        scene: WeatherScene,
        cloudCoveragePercent: Int,
        windSpeedMetersPerSecond: Double,
        animated: Bool
    ) {
        let visible = WeatherBackgroundEffectsPolicy.shouldShowClouds(
            scene: scene,
            cloudCoveragePercent: cloudCoveragePercent
        )
        isHidden = !visible
        guard visible else {
            stopMotion()
            return
        }

        configuredScene = scene
        configuredCoverage = cloudCoveragePercent
        configuredWindSpeed = windSpeedMetersPerSecond
        configuredOpacity = CGFloat(min(
            WeatherBackgroundConstants.Cloud.maxOpacity,
            Float(cloudCoveragePercent) / WeatherBackgroundConstants.Cloud.coverageScale
                * WeatherBackgroundConstants.Cloud.maxOpacity
        ))
        allowsAnimation = animated && !UIAccessibility.isReduceMotionEnabled

        lastRenderedSize = .zero
        lastLayoutSize = .zero
        appliedMotionSignature = nil
        setNeedsLayout()
        layoutIfNeeded()
        applyMotionIfNeeded()
    }

    private func layoutBands() {
        guard bounds.width > 0, bounds.height > 0 else { return }
        guard bounds.size != lastLayoutSize else { return }

        lastLayoutSize = bounds.size
        let textureWidth = WeatherBackgroundMotionPolicy.cloudTextureWidth(for: bounds.width)
        let insetX = (textureWidth - bounds.width) / 2

        backBand.frame = CGRect(
            x: -insetX,
            y: 0,
            width: textureWidth,
            height: bounds.height
        )
        frontBand.frame = CGRect(
            x: -insetX,
            y: WeatherBackgroundConstants.Cloud.frontBandVerticalOffset,
            width: textureWidth,
            height: bounds.height
        )
    }

    private func refreshTexturesIfNeeded() {
        guard !isHidden else { return }

        let bandSize = bounds.size
        guard bandSize.width > 0, bandSize.height > 0 else { return }
        guard bandSize != lastRenderedSize else { return }

        lastRenderedSize = bandSize
        let density = WeatherBackgroundCloudPolicy.density(
            scene: configuredScene,
            cloudCoveragePercent: configuredCoverage
        )
        let isWideLayout = WeatherBackgroundCloudPolicy.isWideLayout(width: bandSize.width)
        let textureSize = CGSize(
            width: WeatherBackgroundMotionPolicy.cloudTextureWidth(for: bandSize.width),
            height: bandSize.height
        )

        backBand.image = WeatherBackgroundAssetFactory.cloudSkyTexture(
            size: textureSize,
            density: WeatherBackgroundCloudPolicy.adjustedLayerDensity(density, wide: isWideLayout, layer: .back),
            variant: WeatherBackgroundConstants.Cloud.backTextureVariant,
            layerPhase: WeatherBackgroundConstants.Cloud.backLayerPhase
        )
        frontBand.image = WeatherBackgroundAssetFactory.cloudSkyTexture(
            size: textureSize,
            density: WeatherBackgroundCloudPolicy.adjustedLayerDensity(density, wide: isWideLayout, layer: .front),
            variant: WeatherBackgroundConstants.Cloud.frontTextureVariant,
            layerPhase: WeatherBackgroundConstants.Cloud.frontLayerPhase
        )

        backBand.alpha = configuredOpacity * WeatherBackgroundCloudPolicy.bandOpacityMultiplier(wide: isWideLayout, layer: .back)
        frontBand.alpha = configuredOpacity * WeatherBackgroundCloudPolicy.bandOpacityMultiplier(wide: isWideLayout, layer: .front)
    }

    private func applyMotionIfNeeded() {
        guard allowsAnimation, !isHidden, bounds.width > 0 else { return }

        let drift = WeatherBackgroundMotionPolicy.cloudDrift(windSpeed: configuredWindSpeed)
        let signature = "\(drift.backDistance)-\(drift.frontDistance)-\(drift.duration)-\(configuredWindSpeed)"
        guard signature != appliedMotionSignature else { return }
        appliedMotionSignature = signature

        startDrift(on: backBand, distance: drift.backDistance, duration: drift.duration)
        startDrift(
            on: frontBand,
            distance: drift.frontDistance,
            duration: drift.duration * WeatherBackgroundConstants.Animation.cloudFrontDurationScale
        )
    }

    private func startDrift(on view: UIView, distance: CGFloat, duration: TimeInterval) {
        view.layer.removeAllAnimations()
        view.transform = .identity

        let drift = CABasicAnimation(keyPath: "transform.translation.x")
        drift.fromValue = 0
        drift.toValue = distance
        drift.duration = duration
        drift.autoreverses = true
        drift.repeatCount = .infinity
        drift.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        view.layer.add(drift, forKey: "cloudDrift")
    }

    private func stopMotion() {
        allowsAnimation = false
        appliedMotionSignature = nil
        [backBand, frontBand].forEach { band in
            band.layer.removeAllAnimations()
            band.transform = .identity
        }
    }
}
