import UIKit
import WeatherCore

final class WeatherBackgroundView: UIView {
    private let backGradient = CAGradientLayer()
    private let frontGradient = CAGradientLayer()
    private let cloudParallax = WeatherCloudParallaxView()
    private let celestialGlow = WeatherCelestialGlowView()
    private let stormFlash = WeatherStormFlashView()
    private var particleEmitter: CAEmitterLayer?
    private var snapshotOverlayLayer: CALayer?

    private var activeIsFront = true
    private var currentConfiguration = WeatherBackgroundConfiguration.neutral
    private var allowsMotion = true

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        backGradient.frame = bounds
        frontGradient.frame = bounds
        updateParticleEmitterFrame()
        snapshotOverlayLayer?.frame = bounds
    }

    func configureForSnapshot(with configuration: WeatherBackgroundConfiguration) {
        particleEmitter?.removeFromSuperlayer()
        particleEmitter = nil
        snapshotOverlayLayer?.removeFromSuperlayer()
        snapshotOverlayLayer = nil

        currentConfiguration = configuration
        allowsMotion = false

        let palette = WeatherBackgroundPalette.colors(for: configuration.scene)
        backGradient.colors = [palette.top.cgColor, palette.bottom.cgColor]
        backGradient.locations = [
            WeatherBackgroundConstants.Layout.gradientLocationStart,
            WeatherBackgroundConstants.Layout.gradientLocationEnd,
        ]
        backGradient.opacity = 1
        frontGradient.opacity = 0
        backGradient.removeAllAnimations()
        frontGradient.removeAllAnimations()
        activeIsFront = false

        cloudParallax.configure(
            scene: configuration.scene,
            cloudCoveragePercent: configuration.cloudCoveragePercent,
            windSpeedMetersPerSecond: configuration.windSpeedMetersPerSecond,
            animated: false
        )
        celestialGlow.configure(
            scene: configuration.scene,
            windSpeedMetersPerSecond: configuration.windSpeedMetersPerSecond,
            animated: false
        )
        stormFlash.configure(
            active: configuration.scene == .thunderstorm,
            animated: false
        )
        updateSnapshotOverlay(for: configuration)
    }

    func configure(scene: WeatherScene) {
        configure(with: WeatherBackgroundConfiguration(
            scene: scene,
            cloudCoveragePercent: currentConfiguration.cloudCoveragePercent,
            windSpeedMetersPerSecond: currentConfiguration.windSpeedMetersPerSecond
        ))
    }

    func configure(with configuration: WeatherBackgroundConfiguration) {
        let sceneChanged = configuration.scene != currentConfiguration.scene
        let effectsChanged = configuration != currentConfiguration
        guard sceneChanged || effectsChanged else { return }

        currentConfiguration = configuration
        allowsMotion = !UIAccessibility.isReduceMotionEnabled

        if sceneChanged {
            crossfadeGradient(to: configuration.scene)
        }

        cloudParallax.configure(
            scene: configuration.scene,
            cloudCoveragePercent: configuration.cloudCoveragePercent,
            windSpeedMetersPerSecond: configuration.windSpeedMetersPerSecond,
            animated: allowsMotion
        )
        celestialGlow.configure(
            scene: configuration.scene,
            windSpeedMetersPerSecond: configuration.windSpeedMetersPerSecond,
            animated: allowsMotion
        )
        stormFlash.configure(
            active: configuration.scene == .thunderstorm,
            animated: allowsMotion
        )
        updateParticles(for: configuration)
    }

    private func setup() {
        backGradient.startPoint = WeatherBackgroundConstants.Layout.gradientStartPoint
        backGradient.endPoint = WeatherBackgroundConstants.Layout.gradientEndPoint
        frontGradient.startPoint = WeatherBackgroundConstants.Layout.gradientStartPoint
        frontGradient.endPoint = WeatherBackgroundConstants.Layout.gradientEndPoint

        let neutral = WeatherBackgroundPalette.colors(for: .neutral)
        backGradient.colors = [neutral.top.cgColor, neutral.bottom.cgColor]
        frontGradient.colors = [neutral.top.cgColor, neutral.bottom.cgColor]
        backGradient.locations = [
            WeatherBackgroundConstants.Layout.gradientLocationStart,
            WeatherBackgroundConstants.Layout.gradientLocationEnd,
        ]
        frontGradient.locations = [
            WeatherBackgroundConstants.Layout.gradientLocationStart,
            WeatherBackgroundConstants.Layout.gradientLocationEnd,
        ]

        layer.addSublayer(backGradient)
        layer.addSublayer(frontGradient)

        cloudParallax.translatesAutoresizingMaskIntoConstraints = false
        celestialGlow.translatesAutoresizingMaskIntoConstraints = false
        stormFlash.translatesAutoresizingMaskIntoConstraints = false
        addSubview(cloudParallax)
        addSubview(celestialGlow)
        addSubview(stormFlash)

        NSLayoutConstraint.activate([
            cloudParallax.topAnchor.constraint(equalTo: topAnchor),
            cloudParallax.bottomAnchor.constraint(equalTo: bottomAnchor),
            cloudParallax.leadingAnchor.constraint(equalTo: leadingAnchor),
            cloudParallax.trailingAnchor.constraint(equalTo: trailingAnchor),

            celestialGlow.topAnchor.constraint(equalTo: topAnchor),
            celestialGlow.bottomAnchor.constraint(equalTo: bottomAnchor),
            celestialGlow.leadingAnchor.constraint(equalTo: leadingAnchor),
            celestialGlow.trailingAnchor.constraint(equalTo: trailingAnchor),

            stormFlash.topAnchor.constraint(equalTo: topAnchor),
            stormFlash.bottomAnchor.constraint(equalTo: bottomAnchor),
            stormFlash.leadingAnchor.constraint(equalTo: leadingAnchor),
            stormFlash.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])

        frontGradient.opacity = 0
    }

    private func crossfadeGradient(to scene: WeatherScene) {
        let palette = WeatherBackgroundPalette.colors(for: scene)
        let incoming = activeIsFront ? backGradient : frontGradient
        let outgoing = activeIsFront ? frontGradient : backGradient

        incoming.colors = [palette.top.cgColor, palette.bottom.cgColor]
        incoming.locations = [
            WeatherBackgroundConstants.Layout.gradientLocationStart,
            WeatherBackgroundConstants.Layout.gradientLocationEnd,
        ]
        incoming.opacity = 0

        if !allowsMotion {
            outgoing.colors = incoming.colors
            outgoing.locations = incoming.locations
            outgoing.opacity = 1
            incoming.opacity = 0
            activeIsFront.toggle()
            return
        }

        let fade = CABasicAnimation(keyPath: "opacity")
        fade.fromValue = 0
        fade.toValue = 1
        fade.duration = WeatherBackgroundConstants.Animation.gradientCrossfadeDuration
        fade.fillMode = .forwards
        fade.isRemovedOnCompletion = false
        incoming.add(fade, forKey: WeatherBackgroundConstants.Animation.Key.fadeIn)
        incoming.opacity = 1

        let fadeOut = CABasicAnimation(keyPath: "opacity")
        fadeOut.fromValue = 1
        fadeOut.toValue = 0
        fadeOut.duration = WeatherBackgroundConstants.Animation.gradientCrossfadeDuration
        fadeOut.fillMode = .forwards
        fadeOut.isRemovedOnCompletion = false
        outgoing.add(fadeOut, forKey: WeatherBackgroundConstants.Animation.Key.fadeOut)
        outgoing.opacity = 0

        activeIsFront.toggle()
    }

    private func updateParticles(for configuration: WeatherBackgroundConfiguration) {
        particleEmitter?.removeFromSuperlayer()
        particleEmitter = nil

        guard allowsMotion else { return }

        guard let emitter = WeatherParticleEmitterBuilder.makeEmitter(
            for: configuration.scene,
            windSpeed: configuration.windSpeedMetersPerSecond,
            bounds: bounds
        ) else {
            return
        }

        particleEmitter = emitter
        layer.addSublayer(emitter)
        updateParticleEmitterFrame()
    }

    private func updateParticleEmitterFrame() {
        guard let particleEmitter else { return }
        particleEmitter.frame = bounds
        particleEmitter.emitterPosition = CGPoint(
            x: bounds.midX,
            y: WeatherBackgroundConstants.Layout.particleEmitterVerticalOffset
        )
        particleEmitter.emitterSize = CGSize(
            width: bounds.width,
            height: WeatherBackgroundConstants.Layout.particleEmitterLineHeight
        )
    }

    private func updateSnapshotOverlay(for configuration: WeatherBackgroundConfiguration) {
        guard bounds.width > 0, bounds.height > 0 else { return }
        guard let density = snapshotPrecipitationDensity(for: configuration.scene) else { return }

        let image = WeatherBackgroundAssetFactory.precipitationOverlayImage(
            density: density,
            size: bounds.size
        )
        let overlay = CALayer()
        overlay.frame = bounds
        overlay.contents = image.cgImage
        snapshotOverlayLayer = overlay
        layer.addSublayer(overlay)
    }

    private func snapshotPrecipitationDensity(
        for scene: WeatherScene
    ) -> WeatherBackgroundAssetFactory.PrecipitationOverlayDensity? {
        switch scene {
        case .drizzle:
            return .drizzle
        case .rain:
            return .rain
        case .thunderstorm:
            return .storm
        case .snow:
            return .snow
        default:
            return nil
        }
    }

    func snapshotRepresentation() -> WeatherBackgroundSnapshotRepresentation {
        let palette = WeatherBackgroundPalette.colors(for: currentConfiguration.scene)
        let showsClouds = WeatherBackgroundEffectsPolicy.shouldShowClouds(
            scene: currentConfiguration.scene,
            cloudCoveragePercent: currentConfiguration.cloudCoveragePercent
        )
        let cloudOpacity = showsClouds
            ? Double(min(
                WeatherBackgroundConstants.Cloud.maxOpacity,
                Float(currentConfiguration.cloudCoveragePercent)
                    / WeatherBackgroundConstants.Cloud.coverageScale
                    * WeatherBackgroundConstants.Cloud.maxOpacity
            ))
            : 0

        return WeatherBackgroundSnapshotRepresentation(
            scene: currentConfiguration.scene.rawValue,
            cloudCoveragePercent: currentConfiguration.cloudCoveragePercent,
            windSpeedMetersPerSecond: currentConfiguration.windSpeedMetersPerSecond,
            canvasSize: .init(
                width: Double(bounds.width),
                height: Double(bounds.height)
            ),
            gradient: .init(
                top: palette.top.rgbaHex,
                bottom: palette.bottom.rgbaHex
            ),
            effects: .init(
                showsCloudParallax: isCloudParallaxVisible,
                cloudOpacity: cloudOpacity,
                celestialKind: snapshotCelestialKindName(for: currentConfiguration.scene),
                showsCelestialGlow: isCelestialGlowVisible,
                showsStormFlash: isStormFlashActive,
                precipitationOverlay: snapshotPrecipitationOverlayKind(
                    for: currentConfiguration.scene
                ),
                hasParticleEmitter: hasActiveParticleEmitter
            )
        )
    }

    private func snapshotCelestialKindName(for scene: WeatherScene) -> String {
        switch WeatherBackgroundEffectsPolicy.celestialKind(for: scene) {
        case .none:
            return "none"
        case .sun:
            return "sun"
        case .moon:
            return "moon"
        }
    }

    private func snapshotPrecipitationOverlayKind(for scene: WeatherScene) -> String? {
        guard snapshotOverlayLayer != nil else { return nil }

        switch scene {
        case .drizzle:
            return "drizzle"
        case .rain:
            return "rain"
        case .thunderstorm:
            return "storm"
        case .snow:
            return "snow"
        default:
            return nil
        }
    }
}

extension WeatherBackgroundView {
    var hasActiveParticleEmitter: Bool { particleEmitter != nil }
    var isCloudParallaxVisible: Bool { !cloudParallax.isHidden }
    var isCelestialGlowVisible: Bool { !celestialGlow.isHidden }
    var isStormFlashActive: Bool { !stormFlash.isHidden }
}
