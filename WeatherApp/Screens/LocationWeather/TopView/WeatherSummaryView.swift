import UIKit
import WeatherCore

class WeatherSummaryView: UIView {
    private let cityLabel = UILabel()
    private let temperatureLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let highLowLabel = UILabel()
    private let feelsLikeLabel = UILabel()
    private let iconView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setup() {
        backgroundColor = .clear

        cityLabel.font = WeatherDesignSystem.Typography.preferred(.title1)
        cityLabel.adjustsFontForContentSizeCategory = true
        cityLabel.textAlignment = .center
        WeatherSkyReadableText.applyPrimary(to: cityLabel)

        temperatureLabel.font = WeatherDesignSystem.Typography.scaledTemperatureDisplay()
        temperatureLabel.adjustsFontForContentSizeCategory = true
        temperatureLabel.textAlignment = .center
        WeatherSkyReadableText.applyPrimary(to: temperatureLabel)

        descriptionLabel.font = WeatherDesignSystem.Typography.preferred(.title3)
        descriptionLabel.adjustsFontForContentSizeCategory = true
        descriptionLabel.textAlignment = .center
        WeatherSkyReadableText.applySecondary(to: descriptionLabel)

        highLowLabel.font = WeatherDesignSystem.Typography.preferred(.body)
        highLowLabel.adjustsFontForContentSizeCategory = true
        highLowLabel.textAlignment = .center
        WeatherSkyReadableText.applySecondary(to: highLowLabel)

        feelsLikeLabel.font = WeatherDesignSystem.Typography.preferred(.subheadline)
        feelsLikeLabel.adjustsFontForContentSizeCategory = true
        feelsLikeLabel.textAlignment = .center
        WeatherSkyReadableText.applySecondary(to: feelsLikeLabel)

        iconView.contentMode = .scaleAspectFit

        let stack = UIStackView(arrangedSubviews: [
            cityLabel,
            iconView,
            temperatureLabel,
            descriptionLabel,
            highLowLabel,
            feelsLikeLabel,
        ])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = WeatherDesignSystem.Spacing.sm
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
        ])
    }

    func configure(with data: LocationWeatherDisplayData) {
        cityLabel.text = "\(data.cityName), \(data.countryCode)"
        temperatureLabel.text = data.currentTemperature
        descriptionLabel.text = data.weatherDescription
        highLowLabel.text = data.tempRange
        feelsLikeLabel.text = data.feelsLike

        guard let iconURL = data.iconURL else {
            iconView.image = nil
            return
        }

        Task {
            do {
                let (imageData, _) = try await URLSession.shared.data(from: iconURL)
                if let image = UIImage(data: imageData) {
                    await MainActor.run { self.iconView.image = image }
                }
            } catch {}
        }
    }
}
