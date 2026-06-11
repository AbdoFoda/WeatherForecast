import UIKit
import WeatherCore

final class WeatherSummaryView: UIView {
    private let cityLabel = UILabel()
    private let temperatureLabel = UILabel()
    private let descriptionLabel = UILabel()
    private let highLowLabel = UILabel()
    private let feelsLikeLabel = UILabel()
    private let detailsStack = UIStackView()
    private let iconView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        applyLayout(for: traitCollection)
    }

    private func setup() {
        backgroundColor = .clear

        cityLabel.font = UIFont.preferredFont(forTextStyle: .title1)
        cityLabel.adjustsFontForContentSizeCategory = true
        cityLabel.textAlignment = .center
        WeatherSkyReadableText.applyPrimary(to: cityLabel)

        temperatureLabel.font = UIFontMetrics(forTextStyle: .largeTitle).scaledFont(for: UIFont.systemFont(ofSize: 72, weight: .thin))
        temperatureLabel.adjustsFontForContentSizeCategory = true
        temperatureLabel.textAlignment = .center
        WeatherSkyReadableText.applyPrimary(to: temperatureLabel)

        descriptionLabel.font = UIFont.preferredFont(forTextStyle: .title3)
        descriptionLabel.adjustsFontForContentSizeCategory = true
        descriptionLabel.textAlignment = .center
        WeatherSkyReadableText.applySecondary(to: descriptionLabel)

        highLowLabel.font = UIFont.preferredFont(forTextStyle: .body)
        highLowLabel.adjustsFontForContentSizeCategory = true
        highLowLabel.textAlignment = .center
        WeatherSkyReadableText.applySecondary(to: highLowLabel)

        feelsLikeLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        feelsLikeLabel.adjustsFontForContentSizeCategory = true
        feelsLikeLabel.textAlignment = .center
        WeatherSkyReadableText.applySecondary(to: feelsLikeLabel)

        iconView.contentMode = .scaleAspectFit

        detailsStack.axis = .vertical
        detailsStack.spacing = 4
        detailsStack.alignment = .center
        detailsStack.isHidden = true

        let stack = UIStackView(arrangedSubviews: [
            cityLabel, iconView, temperatureLabel, descriptionLabel, highLowLabel, feelsLikeLabel, detailsStack
        ])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 10
        stack.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 8),
            stack.leadingAnchor.constraint(
                equalTo: leadingAnchor,
                constant: 20
            ),
            stack.trailingAnchor.constraint(
                equalTo: trailingAnchor,
                constant: -20
            ),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8),
            iconView.heightAnchor.constraint(equalToConstant: 56),
            iconView.widthAnchor.constraint(equalToConstant: 56),
        ])

        applyLayout(for: traitCollection)
    }

    private func applyLayout(for traits: UITraitCollection) {
        let isRegular = traits.horizontalSizeClass == .regular
        detailsStack.isHidden = true
        feelsLikeLabel.isHidden = isRegular
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
