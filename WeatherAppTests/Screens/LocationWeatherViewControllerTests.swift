import XCTest
import WeatherCore
@testable import WeatherApp

@MainActor
final class MockLocationWeatherViewModel: LocationWeatherViewModelProtocol {
    var onStateChange: ((LocationWeatherViewState) -> Void)?

    func loadWeather(lat: Double, lon: Double) async {}
    func refresh(lat: Double, lon: Double) async {}

    func emit(_ state: LocationWeatherViewState) {
        onStateChange?(state)
    }
}

@MainActor
final class LocationWeatherViewControllerTests: XCTestCase {
    func test_loadedState_showsContentAndHidesOfflineBanner() {
        let viewModel = MockLocationWeatherViewModel()
        let sut = LocationWeatherViewController(viewModel: viewModel)
        sut.loadViewIfNeeded()

        viewModel.emit(.loaded(sampleDisplayData(), notice: nil))

        let scrollView = sut.view.subviews.compactMap { $0 as? UIScrollView }.first
        XCTAssertEqual(scrollView?.isHidden, false)
    }

    func test_loadedWithOfflineNotice_showsBanner() {
        let viewModel = MockLocationWeatherViewModel()
        let sut = LocationWeatherViewController(viewModel: viewModel)
        sut.loadViewIfNeeded()

        viewModel.emit(.loaded(sampleDisplayData(), notice: .offline))

        let banner = sut.view.subviews.compactMap { $0 as? OfflineBannerView }.first
        XCTAssertEqual(banner?.isHidden, false)
    }

    func test_loadedState_configuresAnimatedBackground() {
        let viewModel = MockLocationWeatherViewModel()
        let sut = LocationWeatherViewController(viewModel: viewModel)
        sut.loadViewIfNeeded()

        var rainyData = sampleDisplayData()
        rainyData = LocationWeatherDisplayData(
            cityName: rainyData.cityName,
            countryCode: rainyData.countryCode,
            currentTemperature: rainyData.currentTemperature,
            feelsLike: rainyData.feelsLike,
            tempRange: rainyData.tempRange,
            weatherDescription: rainyData.weatherDescription,
            iconURL: rainyData.iconURL,
            humidity: rainyData.humidity,
            pressure: rainyData.pressure,
            windSpeed: rainyData.windSpeed,
            visibility: rainyData.visibility,
            sunrise: rainyData.sunrise,
            sunset: rainyData.sunset,
            aqi: rainyData.aqi,
            pm25: rainyData.pm25,
            cloudCoverage: rainyData.cloudCoverage,
            backgroundScene: .rain,
            cloudCoveragePercent: 80,
            windSpeedMetersPerSecond: 6,
            hourlyItems: [],
            tiles: []
        )

        viewModel.emit(.loaded(rainyData, notice: nil))

        let background = sut.view.subviews.compactMap { $0 as? WeatherBackgroundView }.first
        XCTAssertTrue(background?.hasActiveParticleEmitter ?? false)
    }

    func test_unavailable_hidesScrollContent() {
        let viewModel = MockLocationWeatherViewModel()
        let sut = LocationWeatherViewController(viewModel: viewModel)
        sut.loadViewIfNeeded()

        viewModel.emit(.unavailable(notice: nil))

        let scrollView = sut.view.subviews.compactMap { $0 as? UIScrollView }.first
        XCTAssertEqual(scrollView?.isHidden, true)
    }

    private func sampleDisplayData() -> LocationWeatherDisplayData {
        LocationWeatherDisplayData(
            cityName: "Berlin",
            countryCode: "DE",
            currentTemperature: "18°",
            feelsLike: "Feels like 17°",
            tempRange: "H:20° L:12°",
            weatherDescription: "Clear",
            iconURL: nil,
            humidity: "50%",
            pressure: "1013 hPa",
            windSpeed: "3.0 m/s N",
            visibility: "10 km",
            sunrise: "06:00",
            sunset: "20:00",
            aqi: "Good",
            pm25: "5.0 μg/m³",
            cloudCoverage: "0%",
            backgroundScene: .clearDay,
            cloudCoveragePercent: 0,
            windSpeedMetersPerSecond: 3,
            hourlyItems: [],
            tiles: []
        )
    }
}
