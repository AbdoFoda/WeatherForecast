import UIKit
import WeatherCore

final class WeatherBackgroundView: UIView {
    private let backGradient = CAGradientLayer()
    private let frontGradient = CAGradientLayer()
    private var activeIsFront = true
    private var currentScene: WeatherScene = .neutral

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
    }

    func configure(scene: WeatherScene) {
        guard scene != currentScene else { return }
        currentScene = scene

        let palette = WeatherBackgroundPalette.colors(for: scene)
        let incoming = activeIsFront ? backGradient : frontGradient
        let outgoing = activeIsFront ? frontGradient : backGradient

        incoming.colors = [palette.top.cgColor, palette.bottom.cgColor]
        incoming.locations = [0, 1]
        incoming.opacity = 0

        if UIAccessibility.isReduceMotionEnabled {
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
        fade.duration = 0.6
        fade.fillMode = .forwards
        fade.isRemovedOnCompletion = false
        incoming.add(fade, forKey: "fadeIn")
        incoming.opacity = 1

        let fadeOut = CABasicAnimation(keyPath: "opacity")
        fadeOut.fromValue = 1
        fadeOut.toValue = 0
        fadeOut.duration = 0.6
        fadeOut.fillMode = .forwards
        fadeOut.isRemovedOnCompletion = false
        outgoing.add(fadeOut, forKey: "fadeOut")
        outgoing.opacity = 0

        activeIsFront.toggle()
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
        frontGradient.opacity = 0
    }
}
