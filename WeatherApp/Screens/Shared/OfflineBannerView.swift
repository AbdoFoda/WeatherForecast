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

    func setMessage(_ message: String) {
        label.text = message
    }

    private func setup() {
        backgroundColor = WeatherDesignSystem.Banner.backgroundColor
        layer.cornerRadius = WeatherDesignSystem.Banner.cornerRadius
        layer.masksToBounds = true

        label.text = L10n.Notice.offline
        label.font = WeatherDesignSystem.Typography.preferred(.footnote)
        label.textColor = .label
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        addSubview(label)

        NSLayoutConstraint.activate([
            label.topAnchor.constraint(equalTo: topAnchor, constant: WeatherDesignSystem.Banner.verticalPadding),
            label.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -WeatherDesignSystem.Banner.verticalPadding),
            label.leadingAnchor.constraint(equalTo: leadingAnchor, constant: WeatherDesignSystem.Banner.horizontalPadding),
            label.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -WeatherDesignSystem.Banner.horizontalPadding),
        ])
    }
}
