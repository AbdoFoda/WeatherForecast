import UIKit
import WeatherCore

final class WeatherSummaryView: UIView {
    let cityLabel = UILabel()
    let temperatureLabel = UILabel()
    let descriptionLabel = UILabel()
    let highLowLabel = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        let stack = UIStackView(arrangedSubviews: [cityLabel, temperatureLabel, descriptionLabel, highLowLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 8
        stack.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor, constant: 40),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -40)
        ])
        
        cityLabel.font = UIFont.preferredFont(forTextStyle: .largeTitle)
        cityLabel.adjustsFontForContentSizeCategory = true
        
        temperatureLabel.font = UIFont.systemFont(ofSize: 64, weight: .thin)
        
        descriptionLabel.font = UIFont.preferredFont(forTextStyle: .title2)
        descriptionLabel.adjustsFontForContentSizeCategory = true
        
        highLowLabel.font = UIFont.preferredFont(forTextStyle: .title3)
        highLowLabel.adjustsFontForContentSizeCategory = true
    }
    
    func configure(with data: LocationWeatherDisplayData) {
        cityLabel.text = data.cityName
        temperatureLabel.text = data.currentTemperature
        descriptionLabel.text = data.weatherDescription
        highLowLabel.text = data.tempRange
    }
}
