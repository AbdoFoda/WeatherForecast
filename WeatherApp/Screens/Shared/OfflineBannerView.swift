import UIKit
import WeatherCore

final class OfflineBannerView: UIView {
    private let label = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    var displayedMessage: String? { label.text }

    func setMessage(_ message: String) {
        label.text = message
        accessibilityLabel = message
    }

    func setHidden(_ hidden: Bool, animated: Bool) {
        guard animated else {
            alpha = hidden ? 0 : 1
            isHidden = hidden
            return
        }

        if hidden {
            UIView.animate(
                withDuration: WeatherDesignSystem.Banner.transitionDuration,
                animations: { self.alpha = 0 },
                completion: { _ in self.isHidden = true }
            )
        } else {
            alpha = 0
            isHidden = false
            UIView.animate(withDuration: WeatherDesignSystem.Banner.transitionDuration) {
                self.alpha = 1
            }
        }
    }

    private func setup() {
        backgroundColor = WeatherDesignSystem.Banner.backgroundColor
        layer.cornerRadius = WeatherDesignSystem.Banner.cornerRadius
        layer.masksToBounds = true
        isAccessibilityElement = true
        accessibilityIdentifier = AccessibilityIdentifier.Banner.offline
        accessibilityLabel = L10n.Notice.offline

        label.text = L10n.Notice.offline
        label.font = WeatherDesignSystem.Typography.preferred(.footnote)
        label.textColor = .label
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)

        let horizontalPadding = WeatherDesignSystem.Banner.horizontalPadding
        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: WeatherDesignSystem.Banner.verticalPadding),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -WeatherDesignSystem.Banner.verticalPadding),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: horizontalPadding),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -horizontalPadding)
        ])
    }
}
