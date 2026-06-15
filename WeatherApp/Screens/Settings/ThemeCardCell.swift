import UIKit

final class ThemeCardCell: UICollectionViewCell {
    static let reuseIdentifier = "ThemeCardCell"

    private let gradientView = GradientView()
    private let nameLabel = UILabel()
    private let checkmark = UIImageView()
    private let primarySwatch = UIView()
    private let secondarySwatch = UIView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        contentView.layer.cornerRadius = WeatherDesignSystem.ThemeSettings.cardCornerRadius
        contentView.layer.cornerCurve = .continuous
        contentView.clipsToBounds = true

        gradientView.gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientView.gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientView.frame = contentView.bounds
        gradientView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.addSubview(gradientView)

        nameLabel.font = WeatherDesignSystem.Typography.scaled(.headline, size: 17, weight: .semibold)
        nameLabel.textColor = .white
        nameLabel.translatesAutoresizingMaskIntoConstraints = false

        checkmark.image = UIImage(systemName: "checkmark.circle.fill")
        checkmark.tintColor = .white
        checkmark.contentMode = .scaleAspectFit
        checkmark.translatesAutoresizingMaskIntoConstraints = false

        [primarySwatch, secondarySwatch].forEach {
            $0.layer.cornerRadius = WeatherDesignSystem.ThemeSettings.swatchSize / 2
            $0.layer.borderWidth = 1.5
            $0.layer.borderColor = UIColor.white.withAlphaComponent(0.85).cgColor
            $0.translatesAutoresizingMaskIntoConstraints = false
        }

        let swatches = UIStackView(arrangedSubviews: [primarySwatch, secondarySwatch])
        swatches.axis = .horizontal
        swatches.spacing = 6
        swatches.translatesAutoresizingMaskIntoConstraints = false

        [gradientView, nameLabel, checkmark, swatches].forEach(contentView.addSubview)

        let padding = WeatherDesignSystem.ThemeSettings.cardPadding
        let swatchSize = WeatherDesignSystem.ThemeSettings.swatchSize
        NSLayoutConstraint.activate([
            checkmark.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            checkmark.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -padding),
            checkmark.widthAnchor.constraint(equalToConstant: 24),
            checkmark.heightAnchor.constraint(equalToConstant: 24),

            swatches.topAnchor.constraint(equalTo: contentView.topAnchor, constant: padding),
            swatches.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            primarySwatch.widthAnchor.constraint(equalToConstant: swatchSize),
            primarySwatch.heightAnchor.constraint(equalToConstant: swatchSize),
            secondarySwatch.widthAnchor.constraint(equalToConstant: swatchSize),
            secondarySwatch.heightAnchor.constraint(equalToConstant: swatchSize),

            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: padding),
            nameLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -padding)
        ])
    }

    func configure(with palette: ThemePalette, isSelected: Bool) {
        nameLabel.text = palette.displayName
        gradientView.gradientLayer.colors = [
            palette.tintTop.cgColor,
            palette.tintBottom.cgColor
        ]
        primarySwatch.backgroundColor = palette.accent
        secondarySwatch.backgroundColor = palette.secondary
        checkmark.isHidden = !isSelected

        contentView.layer.borderWidth = isSelected ? 3 : 0
        contentView.layer.borderColor = isSelected
            ? palette.secondary.withAlphaComponent(0.95).cgColor
            : UIColor.clear.cgColor

        if isSelected {
            contentView.layer.shadowColor = palette.accent.cgColor
            contentView.layer.shadowOpacity = 0.6
            contentView.layer.shadowRadius = 12
            contentView.layer.shadowOffset = .zero
            contentView.layer.masksToBounds = false
            layer.masksToBounds = false
        } else {
            contentView.layer.shadowOpacity = 0
        }
    }
}
