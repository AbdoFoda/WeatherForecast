import UIKit
import WeatherCore

final class WeatherBackgroundView: UIView {
    private let backGradient = CAGradientLayer()
    private let frontGradient = CAGradientLayer()
    private let cloudParallax = WeatherCloudParallaxView()
    private let celestialGlow = WeatherCelestialGlowView()
    private let stormFlash = WeatherStormFlashView()
    private var particleEmitter: CAEmitterLayer?

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
            animated: allowsMotion
        )
        celestialGlow.configure(scene: configuration.scene, animated: allowsMotion)
        stormFlash.configure(
            active: configuration.scene == .thunderstorm,
            animated: allowsMotion
        )
        updateParticles(for: configuration)
    }

    private func setup() {
        backGradient.startPoint = CGPoint(x: 0.5, y: 0)
        backGradient.endPoint = CGPoint(x: 0.5, y: 1)
        frontGradient.startPoint = CGPoint(x: 0.5, y: 0)
        frontGradient.endPoint = CGPoint(x: 0.5, y: 1)

        let neutral = WeatherBackgroundPalette.colors(for: .neutral)
        backGradient.colors = [neutral.top.cgColor, neutral.bottom.cgColor]
        frontGradient.colors = [neutral.top.cgColor, neutral.bottom.cgColor]
        backGradient.locations = [0, 1]
        frontGradient.locations = [0, 1]

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
        incoming.locations = [0, 1]
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
        fade.duration = WeatherBackgroundConstants.gradientCrossfadeDuration
        fade.fillMode = .forwards
        fade.isRemovedOnCompletion = false
        incoming.add(fade, forKey: "fadeIn")
        incoming.opacity = 1

        let fadeOut = CABasicAnimation(keyPath: "opacity")
        fadeOut.fromValue = 1
        fadeOut.toValue = 0
        fadeOut.duration = WeatherBackgroundConstants.gradientCrossfadeDuration
        fadeOut.fillMode = .forwards
        fadeOut.isRemovedOnCompletion = false
        outgoing.add(fadeOut, forKey: "fadeOut")
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
        particleEmitter.emitterPosition = CGPoint(x: bounds.midX, y: -8)
        particleEmitter.emitterSize = CGSize(width: bounds.width, height: 1)
    }
}

extension WeatherBackgroundView {
    var hasActiveParticleEmitter: Bool { particleEmitter != nil }
    var isCloudParallaxVisible: Bool { !cloudParallax.isHidden }
    var isCelestialGlowVisible: Bool { !celestialGlow.isHidden }
    var isStormFlashActive: Bool { !stormFlash.isHidden }
}
