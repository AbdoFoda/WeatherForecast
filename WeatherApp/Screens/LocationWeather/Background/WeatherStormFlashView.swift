import UIKit
import WeatherCore

final class WeatherStormFlashView: UIView {
    private var flashTimer: Timer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        isUserInteractionEnabled = false
        backgroundColor = UIColor.white.withAlphaComponent(0)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        flashTimer?.invalidate()
    }

    func configure(active: Bool, animated: Bool) {
        flashTimer?.invalidate()
        flashTimer = nil
        layer.removeAllAnimations()
        backgroundColor = UIColor.white.withAlphaComponent(0)
        isHidden = !active

        guard active, animated, !UIAccessibility.isReduceMotionEnabled else { return }

        flashTimer = Timer.scheduledTimer(
            withTimeInterval: WeatherBackgroundConstants.Storm.flashInterval,
            repeats: true
        ) { [weak self] _ in
            self?.playFlash()
        }
        flashTimer?.tolerance = WeatherBackgroundConstants.Storm.flashTimerTolerance
    }

    private func playFlash() {
        UIView.animate(
            withDuration: WeatherBackgroundConstants.Storm.flashPeakDuration,
            animations: {
                self.backgroundColor = UIColor.white.withAlphaComponent(
                    WeatherBackgroundConstants.Storm.flashPeakAlpha
                )
            },
            completion: { _ in
                UIView.animate(withDuration: WeatherBackgroundConstants.Storm.flashFadeDuration) {
                    self.backgroundColor = UIColor.white.withAlphaComponent(0)
                }
            }
        )
    }
}
