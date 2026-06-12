import XCTest
@testable import WeatherCore

final class WeatherDiskCacheTests: XCTestCase {
    private var cacheDirectory: URL!

    override func setUp() {
        super.setUp()
        cacheDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString, isDirectory: true)
    }

    override func tearDown() {
        try? FileManager.default.removeItem(at: cacheDirectory)
        super.tearDown()
    }

    func test_load_returnsNilWhenMissing() {
        let sut = WeatherDiskCache(directoryURL: cacheDirectory)
        XCTAssertNil(sut.load(lat: 52.52, lon: 13.40))
    }

    func test_saveAndLoad_roundTrip() {
        let sut = WeatherDiskCache(directoryURL: cacheDirectory)
        let display = sampleDisplayData()

        XCTAssertTrue(sut.save(lat: 52.52, lon: 13.40, displayData: display))

        let entry = sut.load(lat: 52.52, lon: 13.40)
        XCTAssertEqual(entry?.displayData.cityName, "Berlin")
        XCTAssertEqual(entry?.displayData.tiles.count, 1)
        XCTAssertEqual(entry?.latitude, 52.52)
    }

    func test_remove_deletesCachedEntry() {
        let sut = WeatherDiskCache(directoryURL: cacheDirectory)
        sut.save(lat: 48.85, lon: 2.35, displayData: sampleDisplayData())

        sut.remove(lat: 48.85, lon: 2.35)

        XCTAssertNil(sut.load(lat: 48.85, lon: 2.35))
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
            cloudCoverage: "20%",
            backgroundScene: .clearDay,
            cloudCoveragePercent: 20,
            windSpeedMetersPerSecond: 3,
            hourlyItems: [],
            tiles: [
                TileDisplayItem(id: TileKind.humidity.rawValue, title: "Humidity", value: "50%", subtitle: nil, tileSize: .standard)
            ]
        )
    }
}
