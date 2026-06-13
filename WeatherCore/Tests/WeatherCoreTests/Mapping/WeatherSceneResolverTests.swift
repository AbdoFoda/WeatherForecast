import XCTest
@testable import WeatherCore

final class WeatherSceneResolverTests: XCTestCase {
    func test_resolve_clearDay() {
        let weather = makeWeather(conditionID: 800, icon: "01d", clouds: 0)
        XCTAssertEqual(WeatherSceneResolver.resolve(from: weather), .clearDay)
    }

    func test_resolve_clearNight() {
        let weather = makeWeather(conditionID: 800, icon: "01n", clouds: 0)
        XCTAssertEqual(WeatherSceneResolver.resolve(from: weather), .clearNight)
    }

    func test_resolve_partlyCloudyDay() {
        let weather = makeWeather(conditionID: 802, icon: "03d", clouds: 40)
        XCTAssertEqual(WeatherSceneResolver.resolve(from: weather), .partlyCloudyDay)
    }

    func test_resolve_cloudy() {
        let weather = makeWeather(conditionID: 804, icon: "04d", clouds: 90)
        XCTAssertEqual(WeatherSceneResolver.resolve(from: weather), .cloudy)
    }

    func test_resolve_rain() {
        let weather = makeWeather(conditionID: 500, icon: "10d", clouds: 80)
        XCTAssertEqual(WeatherSceneResolver.resolve(from: weather), .rain)
    }

    func test_resolve_drizzle() {
        let weather = makeWeather(conditionID: 300, icon: "09d", clouds: 70)
        XCTAssertEqual(WeatherSceneResolver.resolve(from: weather), .drizzle)
    }

    func test_resolve_thunderstorm() {
        let weather = makeWeather(conditionID: 211, icon: "11d", clouds: 90)
        XCTAssertEqual(WeatherSceneResolver.resolve(from: weather), .thunderstorm)
    }

    func test_resolve_snow() {
        let weather = makeWeather(conditionID: 600, icon: "13d", clouds: 80)
        XCTAssertEqual(WeatherSceneResolver.resolve(from: weather), .snow)
    }

    func test_resolve_fog() {
        let weather = makeWeather(conditionID: 741, icon: "50d", clouds: 100)
        XCTAssertEqual(WeatherSceneResolver.resolve(from: weather), .fog)
    }

    private func makeWeather(conditionID: Int, icon: String, clouds: Int) -> CurrentWeatherResponse {
        CurrentWeatherResponse(
            coord: Coordinate(lat: 52.52, lon: 13.4),
            weather: [WeatherCondition(id: conditionID, main: "Test", description: "test", icon: icon)],
            main: MainWeather(
                temp: 10,
                feelsLike: 10,
                tempMin: 8,
                tempMax: 12,
                pressure: 1013,
                seaLevel: nil,
                grndLevel: nil,
                humidity: 50
            ),
            visibility: 10_000,
            wind: Wind(speed: 3, deg: 180, gust: nil),
            clouds: Clouds(all: clouds),
            rain: nil,
            snow: nil,
            dt: 0,
            sys: Sys(type: nil, id: nil, country: "DE", sunrise: 0, sunset: 0),
            timezone: 0,
            id: 1,
            name: "Berlin"
        )
    }
}
