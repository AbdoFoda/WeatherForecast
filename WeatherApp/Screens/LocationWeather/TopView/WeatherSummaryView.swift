import UIKit
import WeatherCore

class WeatherSummaryView: UIView {
    private let cityLabel = UILabel()
    private let placeLabel = UILabel()
    private let temperatureLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let highLowLabel = UILabel()
    private let iconView = UIImageView()
    private let detailRow = UIStackView()
    private var iconLoadTask: Task<Void, Never>?

    private var displayData: LocationWeatherDisplayData?

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        updateAdaptiveLayout()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        iconLoadTask?.cancel()
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        if traitCollection.horizontalSizeClass != previousTraitCollection?.horizontalSizeClass {
            updateAdaptiveLayout()
        }
    }

    private var isRegularWidth: Bool {
        traitCollection.horizontalSizeClass == .regular
    }

    private func updateAdaptiveLayout() {
        let regular = isRegularWidth
        placeLabel.isHidden = regular ? placeLabel.text?.isEmpty ?? true : true
        detailRow.isHidden = !regular || detailRow.arrangedSubviews.isEmpty
    }

    private func setup() {
        backgroundColor = .clear

        cityLabel.font = WeatherDesignSystem.Typography.preferred(.title1)
        cityLabel.adjustsFontForContentSizeCategory = true
        cityLabel.textAlignment = .center
        cityLabel.numberOfLines = 2
        WeatherSkyReadableText.applyPrimary(to: cityLabel)

        placeLabel.font = WeatherDesignSystem.Typography.preferred(.footnote)
        placeLabel.adjustsFontForContentSizeCategory = true
        placeLabel.textAlignment = .center
        placeLabel.numberOfLines = 1
        WeatherSkyReadableText.applySecondary(to: placeLabel)

        temperatureLabel.font = WeatherDesignSystem.Typography.scaledTemperatureDisplay()
        temperatureLabel.adjustsFontForContentSizeCategory = true
        temperatureLabel.textAlignment = .center
        WeatherSkyReadableText.applyPrimary(to: temperatureLabel)

        descriptionLabel.font = WeatherDesignSystem.Typography.preferred(.title3)
        descriptionLabel.adjustsFontForContentSizeCategory = true
        descriptionLabel.textAlignment = .center
        descriptionLabel.numberOfLines = 2
        WeatherSkyReadableText.applySecondary(to: descriptionLabel)

        highLowLabel.font = WeatherDesignSystem.Typography.preferred(.body)
        highLowLabel.adjustsFontForContentSizeCategory = true
        highLowLabel.textAlignment = .center
        WeatherSkyReadableText.applySecondary(to: highLowLabel)

        detailRow.axis = .horizontal
        detailRow.alignment = .top
        detailRow.distribution = .fillEqually
        detailRow.spacing = WeatherDesignSystem.Spacing.sm

        iconView.contentMode = .scaleAspectFit

        let stack = UIStackView(arrangedSubviews: [
            cityLabel,
            placeLabel,
            iconView,
            temperatureLabel,
            descriptionLabel,
            highLowLabel,
            detailRow,
        ])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = WeatherDesignSystem.Spacing.sm
        stack.setCustomSpacing(WeatherDesignSystem.Spacing.lg, after: highLowLabel)
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: WeatherDesignSystem.Spacing.xs),
            stack.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: WeatherDesignSystem.Layout.summaryHorizontalInset
            ),
            stack.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -WeatherDesignSystem.Layout.summaryHorizontalInset
            ),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -WeatherDesignSystem.Spacing.xs),
            iconView.heightAnchor.constraint(equalToConstant: WeatherDesignSystem.Icon.summaryWeather),
            iconView.widthAnchor.constraint(equalToConstant: WeatherDesignSystem.Icon.summaryWeather),
            detailRow.leadingAnchor.constraint(equalTo: stack.leadingAnchor),
            detailRow.trailingAnchor.constraint(equalTo: stack.trailingAnchor),
        ])
    }

    func configure(with data: LocationWeatherDisplayData) {
        displayData = data
        cityLabel.text = headline(for: data)
        placeLabel.text = placeDetail(for: data)
        temperatureLabel.text = data.currentTemperature
        descriptionLabel.text = data.weatherDescription
        highLowLabel.text = data.tempRange
        rebuildDetailRow(for: data)
        updateAdaptiveLayout()

        iconLoadTask?.cancel()
        iconView.image = nil

        guard let iconURL = data.iconURL else { return }

        iconLoadTask = Task { @MainActor [weak self] in
            guard let (imageData, _) = try? await URLSession.shared.data(from: iconURL),
                  !Task.isCancelled,
                  let image = UIImage(data: imageData) else { return }
            self?.iconView.image = image
        }
    }

    private func headline(for data: LocationWeatherDisplayData) -> String {
        guard !data.countryCode.isEmpty else { return data.cityName }
        return "\(data.cityName), \(data.countryCode)"
    }

    private func placeDetail(for data: LocationWeatherDisplayData) -> String? {
        var parts: [String] = []
        if let zip = data.postalCode, !zip.isEmpty {
            parts.append(zip)
        }
        if let altitude = data.altitude, !altitude.isEmpty {
            parts.append("\(L10n.Summary.elevation) \(altitude)")
        }
        return parts.isEmpty ? nil : parts.joined(separator: "  ·  ")
    }

    private func rebuildDetailRow(for data: LocationWeatherDisplayData) {
        detailRow.arrangedSubviews.forEach {
            detailRow.removeArrangedSubview($0)
            $0.removeFromSuperview()
        }

        var tilesByKind: [TileKind: TileDisplayItem] = [:]
        for tile in data.tiles {
            guard let kind = TileKind(rawValue: tile.id), tilesByKind[kind] == nil else { continue }
            tilesByKind[kind] = tile
        }

        let order: [TileKind] = [.feelsLike, .humidity, .pressure, .air]
        for kind in order {
            guard let tile = tilesByKind[kind] else { continue }
            detailRow.addArrangedSubview(makeMetricChip(title: tile.title, value: tile.value))
        }
    }

    private func makeMetricChip(title: String, value: String) -> UIView {
        let valueLabel = UILabel()
        valueLabel.font = WeatherDesignSystem.Typography.preferred(.headline)
        valueLabel.adjustsFontForContentSizeCategory = true
        valueLabel.textAlignment = .center
        valueLabel.numberOfLines = 1
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.6
        valueLabel.text = value
        WeatherSkyReadableText.applyPrimary(to: valueLabel)

        let titleLabel = UILabel()
        titleLabel.font = WeatherDesignSystem.Typography.preferred(.caption2)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 2
        titleLabel.text = title
        WeatherSkyReadableText.applySecondary(to: titleLabel)

        let chip = UIStackView(arrangedSubviews: [valueLabel, titleLabel])
        chip.axis = .vertical
        chip.alignment = .center
        chip.spacing = WeatherDesignSystem.Spacing.xxs
        return chip
    }
}
