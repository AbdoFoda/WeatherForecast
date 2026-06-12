import UIKit

final class LocationPermissionView: UIView {
    private let messageLabel = UILabel()
    private let settingsButton = UIButton(type: .system)

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = .systemBackground

        messageLabel.text = AppL10n.locationPermissionMessage
        messageLabel.font = WeatherDesignSystem.Typography.preferred(.body)
        messageLabel.adjustsFontForContentSizeCategory = true
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0

        settingsButton.setTitle(AppL10n.openSettings, for: .normal)
        settingsButton.titleLabel?.font = WeatherDesignSystem.Typography.preferred(.headline)
        settingsButton.addTarget(self, action: #selector(openSettings), for: .touchUpInside)

        [messageLabel, settingsButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            messageLabel.centerYAnchor.constraint(
                equalTo: centerYAnchor,
                constant: -WeatherDesignSystem.Layout.permissionMessageVerticalOffset
            ),
            messageLabel.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: WeatherDesignSystem.Layout.permissionHorizontalInset
            ),
            messageLabel.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -WeatherDesignSystem.Layout.permissionHorizontalInset
            ),

            settingsButton.topAnchor.constraint(
                equalTo: messageLabel.bottomAnchor,
                constant: WeatherDesignSystem.Layout.permissionButtonTopSpacing
            ),
            settingsButton.centerXAnchor.constraint(equalTo: centerXAnchor),
        ])
    }

    func configure(message: String) {
        messageLabel.text = message
    }

    @objc private func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
        UIApplication.shared.open(url)
    }
}
