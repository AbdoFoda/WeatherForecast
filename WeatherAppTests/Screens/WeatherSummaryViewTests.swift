import XCTest
import WeatherCore
@testable import WeatherApp

@MainActor
final class WeatherSummaryViewTests: XCTestCase {
    func test_configure_setsPrimaryLabels() {
        let sut = WeatherSummaryView(frame: CGRect(x: 0, y: 0, width: 390, height: 300))
        sut.configure(with: sampleDisplayData())

        XCTAssertTrue(sut.subviews.count > 0)
        XCTAssertEqual(sut.backgroundColor, .clear)
    }

    func test_compactHorizontalSizeClass_keepsSummaryRowsVisible() {
        let sut = TestableWeatherSummaryView(
            frame: CGRect(x: 0, y: 0, width: 390, height: 300),
            horizontalSizeClass: .compact
        )
        sut.configure(with: sampleDisplayData())

        XCTAssertFalse(label(containing: "H:20", in: sut)?.isHidden == true)
        XCTAssertFalse(label(containing: "Feels like", in: sut)?.isHidden == true)
    }

    func test_regularHorizontalSizeClass_keepsSummaryRowsVisible() {
        let sut = TestableWeatherSummaryView(
            frame: CGRect(x: 0, y: 0, width: 820, height: 400),
            horizontalSizeClass: .regular
        )
        sut.configure(with: sampleDisplayData())

        XCTAssertFalse(label(containing: "H:20", in: sut)?.isHidden == true)
        XCTAssertFalse(label(containing: "Feels like", in: sut)?.isHidden == true)
    }

    private func label(containing text: String, in view: UIView) -> UILabel? {
        labels(in: view).first { $0.text?.contains(text) == true }
    }

    private func labels(in view: UIView) -> [UILabel] {
        var found: [UILabel] = []
        if let label = view as? UILabel {
            found.append(label)
        }
        for subview in view.subviews {
            found.append(contentsOf: labels(in: subview))
        }
        return found
    }

    private func sampleDisplayData() -> LocationWeatherDisplayData {
        LocationWeatherDisplayData(
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
    }
}

private final class TestableWeatherSummaryView: WeatherSummaryView {
    private let forcedHorizontalSizeClass: UIUserInterfaceSizeClass

    init(frame: CGRect, horizontalSizeClass: UIUserInterfaceSizeClass) {
        forcedHorizontalSizeClass = horizontalSizeClass
        super.init(frame: frame)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var traitCollection: UITraitCollection {
        UITraitCollection(traitsFrom: [
            super.traitCollection,
            UITraitCollection(horizontalSizeClass: forcedHorizontalSizeClass),
        ])
    }
}
