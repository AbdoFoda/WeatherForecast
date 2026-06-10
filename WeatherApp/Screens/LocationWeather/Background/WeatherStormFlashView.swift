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

        flashTimer = Timer.scheduledTimer(withTimeInterval: 4.5, repeats: true) { [weak self] _ in
            self?.playFlash()
        }
        flashTimer?.tolerance = 1.2
    }

    private func playFlash() {
        UIView.animate(withDuration: 0.08, animations: {
            self.backgroundColor = UIColor.white.withAlphaComponent(0.18)
        }, completion: { _ in
            UIView.animate(withDuration: 0.25) {
                self.backgroundColor = UIColor.white.withAlphaComponent(0)
            }
        })
    }
}
