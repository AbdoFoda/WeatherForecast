import UIKit
import WeatherCore

final class LocationCardView: UIView {
    struct Model {
        let title: String
        let subtitle: String
        let isCurrentLocation: Bool
        let summary: LocationCardSummary?
        let isSelected: Bool
    }

    private let gradientLayer = CAGradientLayer()
    private let scrimLayer = CAGradientLayer()
    private let themeTintLayer = CAGradientLayer()
    private let glassBlur = UIBlurEffect(style: GlassStyle.cardBlur)
    private lazy var glassVeil = UIVisualEffectView(effect: glassBlur)
    private let highlightBorder = CALayer()

    private let nameLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let temperatureLabel = UILabel()
    private let conditionLabel = UILabel()
    private let highLowLabel = UILabel()
    private let locationGlyph = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        layer.cornerRadius = Metrics.cornerRadius
        layer.cornerCurve = .continuous
        clipsToBounds = true

        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        layer.addSublayer(gradientLayer)

        glassVeil.translatesAutoresizingMaskIntoConstraints = false
        glassVeil.isUserInteractionEnabled = false
        addSubview(glassVeil)

        scrimLayer.colors = [
            UIColor.clear.cgColor,
            UIColor.black.withAlphaComponent(0.22).cgColor
        ]
        scrimLayer.locations = [0.45, 1.0]
        layer.addSublayer(scrimLayer)

        themeTintLayer.startPoint = CGPoint(x: 0, y: 0)
        themeTintLayer.endPoint = CGPoint(x: 1, y: 1)
        layer.addSublayer(themeTintLayer)

        highlightBorder.borderColor = UIColor.white.withAlphaComponent(0.18).cgColor
        highlightBorder.borderWidth = 1
        highlightBorder.cornerRadius = Metrics.cornerRadius
        highlightBorder.cornerCurve = .continuous
        layer.addSublayer(highlightBorder)

        configureLabels()
        layoutContent()
    }

    private func configureLabels() {
        nameLabel.font = WeatherDesignSystem.Typography.scaled(.title2, size: 22, weight: .semibold)
        nameLabel.adjustsFontForContentSizeCategory = true
        nameLabel.numberOfLines = 1
        nameLabel.adjustsFontSizeToFitWidth = true
        nameLabel.minimumScaleFactor = 0.7
        nameLabel.lineBreakMode = .byTruncatingTail
        WeatherSkyReadableText.applyPrimary(to: nameLabel)

        subtitleLabel.font = WeatherDesignSystem.Typography.preferred(.footnote)
        subtitleLabel.adjustsFontForContentSizeCategory = true
        WeatherSkyReadableText.applySecondary(to: subtitleLabel)

        temperatureLabel.font = WeatherDesignSystem.Typography.scaled(.largeTitle, size: 44, weight: .thin)
        temperatureLabel.adjustsFontForContentSizeCategory = true
        temperatureLabel.adjustsFontSizeToFitWidth = true
        temperatureLabel.minimumScaleFactor = 0.6
        temperatureLabel.setContentHuggingPriority(.required, for: .horizontal)
        temperatureLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        WeatherSkyReadableText.applyPrimary(to: temperatureLabel)

        conditionLabel.font = WeatherDesignSystem.Typography.preferred(.subheadline)
        conditionLabel.adjustsFontForContentSizeCategory = true
        WeatherSkyReadableText.applySecondary(to: conditionLabel)

        highLowLabel.font = WeatherDesignSystem.Typography.preferred(.subheadline)
        highLowLabel.adjustsFontForContentSizeCategory = true
        highLowLabel.textAlignment = .right
        highLowLabel.setContentHuggingPriority(.required, for: .horizontal)
        WeatherSkyReadableText.applySecondary(to: highLowLabel)

        locationGlyph.image = UIImage(systemName: "location.fill")
        locationGlyph.tintColor = WeatherDesignSystem.SkyText.primaryColor
        locationGlyph.contentMode = .scaleAspectFit
        locationGlyph.setContentHuggingPriority(.required, for: .horizontal)
    }

    private func layoutContent() {
        let titleRow = UIStackView(arrangedSubviews: [locationGlyph, nameLabel])
        titleRow.axis = .horizontal
        titleRow.alignment = .firstBaseline
        titleRow.spacing = WeatherDesignSystem.Spacing.xs

        let leadingTop = UIStackView(arrangedSubviews: [titleRow, subtitleLabel])
        leadingTop.axis = .vertical
        leadingTop.alignment = .leading
        leadingTop.spacing = 2

        let topRow = UIStackView(arrangedSubviews: [leadingTop, temperatureLabel])
        topRow.axis = .horizontal
        topRow.alignment = .top
        topRow.distribution = .fill

        let bottomRow = UIStackView(arrangedSubviews: [conditionLabel, highLowLabel])
        bottomRow.axis = .horizontal
        bottomRow.alignment = .bottom
        bottomRow.distribution = .fill

        let content = UIStackView(arrangedSubviews: [topRow, bottomRow])
        content.axis = .vertical
        content.distribution = .equalSpacing
        content.translatesAutoresizingMaskIntoConstraints = false
        addSubview(content)

        NSLayoutConstraint.activate([
            glassVeil.topAnchor.constraint(equalTo: topAnchor),
            glassVeil.bottomAnchor.constraint(equalTo: bottomAnchor),
            glassVeil.leadingAnchor.constraint(equalTo: leadingAnchor),
            glassVeil.trailingAnchor.constraint(equalTo: trailingAnchor),

            content.topAnchor.constraint(equalTo: topAnchor, constant: Metrics.padding),
            content.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -Metrics.padding),
            content.leadingAnchor.constraint(equalTo: leadingAnchor, constant: Metrics.padding),
            content.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -Metrics.padding),

            locationGlyph.widthAnchor.constraint(equalToConstant: 14)
        ])

        addParallax(to: content, amount: Metrics.parallax)
    }

    private func addParallax(to view: UIView, amount: CGFloat) {
        let horizontal = UIInterpolatingMotionEffect(
            keyPath: "center.x",
            type: .tiltAlongHorizontalAxis
        )
        horizontal.minimumRelativeValue = -amount
        horizontal.maximumRelativeValue = amount

        let vertical = UIInterpolatingMotionEffect(
            keyPath: "center.y",
            type: .tiltAlongVerticalAxis
        )
        vertical.minimumRelativeValue = -amount
        vertical.maximumRelativeValue = amount

        let group = UIMotionEffectGroup()
        group.motionEffects = [horizontal, vertical]
        view.addMotionEffect(group)
    }

    func configure(with model: Model) {
        nameLabel.text = model.title
        subtitleLabel.text = model.subtitle
        locationGlyph.isHidden = !model.isCurrentLocation

        let scene = model.summary?.scene ?? .neutral
        let colors = CardPalette.gradient(for: scene)
        gradientLayer.colors = colors

        let palette = ThemeManager.shared.palette
        themeTintLayer.colors = [
            palette.cardTintTop.withAlphaComponent(WeatherDesignSystem.Glass.cardTintTopAlpha).cgColor,
            palette.cardTintBottom.withAlphaComponent(WeatherDesignSystem.Glass.cardTintBottomAlpha).cgColor
        ]

        if let summary = model.summary {
            temperatureLabel.text = summary.temperature
            conditionLabel.text = summary.conditionText
            highLowLabel.text = summary.highLow
        } else {
            temperatureLabel.text = Metrics.placeholderTemperature
            conditionLabel.text = AppL10n.updating
            highLowLabel.text = nil
        }

        highlightBorder.borderColor = (model.isSelected
            ? palette.selectedBorderColor
            : UIColor.white.withAlphaComponent(0.18)).cgColor
        highlightBorder.borderWidth = model.isSelected ? 2 : 1
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
        scrimLayer.frame = bounds
        themeTintLayer.frame = bounds
        highlightBorder.frame = bounds
    }

    private enum Metrics {
        static let cornerRadius: CGFloat = 22
        static let padding: CGFloat = 16
        static let parallax: CGFloat = 9
        static let placeholderTemperature = "--\u{00B0}"
    }

    private enum CardPalette {
        static func gradient(for scene: WeatherScene) -> [CGColor] {
            let pair = colors(for: scene)
            return [pair.0.cgColor, pair.1.cgColor]
        }

        private static func colors(for scene: WeatherScene) -> (UIColor, UIColor) {
            switch scene {
            case .clearDay:
                return (rgb(0.36, 0.66, 0.90), rgb(0.62, 0.82, 0.95))
            case .clearNight:
                return (rgb(0.17, 0.21, 0.35), rgb(0.29, 0.33, 0.50))
            case .partlyCloudyDay:
                return (rgb(0.44, 0.62, 0.82), rgb(0.70, 0.80, 0.90))
            case .partlyCloudyNight:
                return (rgb(0.21, 0.25, 0.40), rgb(0.33, 0.37, 0.54))
            case .cloudy:
                return (rgb(0.50, 0.55, 0.62), rgb(0.69, 0.73, 0.78))
            case .rain, .drizzle:
                return (rgb(0.33, 0.40, 0.49), rgb(0.49, 0.55, 0.62))
            case .thunderstorm:
                return (rgb(0.24, 0.26, 0.37), rgb(0.38, 0.40, 0.53))
            case .snow:
                return (rgb(0.58, 0.70, 0.82), rgb(0.80, 0.86, 0.92))
            case .fog:
                return (rgb(0.55, 0.59, 0.63), rgb(0.74, 0.77, 0.80))
            case .neutral, .unknown:
                return (rgb(0.53, 0.59, 0.69), rgb(0.72, 0.77, 0.84))
            }
        }

        private static func rgb(_ r: CGFloat, _ g: CGFloat, _ b: CGFloat) -> UIColor {
            UIColor(red: r, green: g, blue: b, alpha: 1)
        }
    }
}
