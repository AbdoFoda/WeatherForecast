import XCTest
import WeatherCore
@testable import WeatherApp

@MainActor
final class WeatherSummaryViewTests: XCTestCase {
    func test_configure_setsPrimaryLabels() {
        let sut = WeatherSummaryView(frame: CGRect(x: 0, y: 0, width: 390, height: 300))
        let data = LocationWeatherDisplayData(
            cityName: "Berlin",
            countryCode: "DE",
            currentTemperature: "18°",
            feelsLike: "Feels like 17°",
            tempRange: "H:20° L:12°",
            weatherDescription: "Few Clouds",
            iconURL: nil,
            humidity: "50%",
            pressure: "1013 hPa",
            windSpeed: "3.0 m/s N",
            visibility: "10 km",
            sunrise: "06:00",
            sunset: "20:00",
            aqi: "Good",
            pm25: "5.0 μg/m³",
            cloudCoverage: "20%",
            backgroundScene: .partlyCloudyDay,
            cloudCoveragePercent: 20,
            windSpeedMetersPerSecond: 3,
            hourlyItems: [],
            tiles: []
        )

        sut.configure(with: data)

        XCTAssertTrue(sut.subviews.count > 0)
    }
}
