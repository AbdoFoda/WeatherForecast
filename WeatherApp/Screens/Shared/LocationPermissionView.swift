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
        messageLabel.font = UIFont.preferredFont(forTextStyle: .body)
        messageLabel.adjustsFontForContentSizeCategory = true
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0

        settingsButton.setTitle(AppL10n.openSettings, for: .normal)
        settingsButton.titleLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        settingsButton.addTarget(self, action: #selector(openSettings), for: .touchUpInside)

        [messageLabel, settingsButton].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            addSubview($0)
        }

        NSLayoutConstraint.activate([
            messageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            messageLabel.centerYAnchor.constraint(equalTo: centerYAnchor, constant: -40),
            messageLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 32),
            messageLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -32),

            settingsButton.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 24),
            settingsButton.centerXAnchor.constraint(equalTo: centerXAnchor)
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
