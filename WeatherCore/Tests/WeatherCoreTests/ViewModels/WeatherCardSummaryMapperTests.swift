import XCTest
@testable import WeatherCore

final class WeatherCardSummaryMapperTests: XCTestCase {
    private func makeResponse(
        temp: Double,
        tempMin: Double,
        tempMax: Double,
        description: String,
        conditionID: Int = 800,
        icon: String = "01d",
        dt: TimeInterval = 1_700_000_000,
        timezone: Int = 3600
    ) -> CurrentWeatherResponse {
        CurrentWeatherResponse(
            coord: Coordinate(lat: 52.52, lon: 13.40),
            weather: [WeatherCondition(id: conditionID, main: "Clear", description: description, icon: icon)],
            main: MainWeather(temp: temp, feelsLike: temp, tempMin: tempMin, tempMax: tempMax, pressure: 1013, seaLevel: nil, grndLevel: nil, humidity: 50),
            visibility: nil,
            wind: nil,
            clouds: nil,
            rain: nil,
            snow: nil,
            dt: dt,
            sys: Sys(type: nil, id: nil, country: "DE", sunrise: 0, sunset: 0),
            timezone: timezone,
            id: 1,
            name: "Berlin"
        )
    }

    func test_map_roundsTemperatureAndHighLow() {
        let response = makeResponse(temp: 19.6, tempMin: 14.7, tempMax: 24.3, description: "clear sky")

        let summary = WeatherCardSummaryMapper.map(weather: response)

        XCTAssertEqual(summary.temperature, L10n.Format.temperature(20))
        XCTAssertEqual(summary.highLow, L10n.Format.tempHighLow(high: 24, low: 15))
    }

    func test_map_capitalizesConditionText() {
        let response = makeResponse(temp: 20, tempMin: 15, tempMax: 25, description: "clear sky")

        let summary = WeatherCardSummaryMapper.map(weather: response)

        XCTAssertEqual(summary.conditionText, "Clear Sky")
    }

    func test_map_emptyConditions_producesEmptyConditionText() {
        var response = makeResponse(temp: 20, tempMin: 15, tempMax: 25, description: "clear sky")
        response = CurrentWeatherResponse(
            coord: response.coord,
            weather: [],
            main: response.main,
            visibility: nil,
            wind: nil,
            clouds: nil,
            rain: nil,
            snow: nil,
            dt: response.dt,
            sys: response.sys,
            timezone: response.timezone,
            id: response.id,
            name: response.name
        )

        let summary = WeatherCardSummaryMapper.map(weather: response)

        XCTAssertEqual(summary.conditionText, "")
    }

    func test_map_localTimeUsesTimezoneOffset() {
        let response = makeResponse(temp: 20, tempMin: 15, tempMax: 25, description: "clear sky", dt: 1_700_000_000, timezone: 3600)

        let summary = WeatherCardSummaryMapper.map(weather: response)

        let tzOffset = TimeInterval(response.timezone)
        let localDate = Date(timeIntervalSince1970: response.dt).addingTimeInterval(tzOffset)
        let expected = WeatherFormatters.time(timezoneOffset: tzOffset).string(from: localDate)
        XCTAssertEqual(summary.localTime, expected)
    }

    func test_map_resolvesSceneFromResponse() {
        let response = makeResponse(temp: 20, tempMin: 15, tempMax: 25, description: "clear sky", conditionID: 800, icon: "01d")

        let summary = WeatherCardSummaryMapper.map(weather: response)

        XCTAssertEqual(summary.scene, WeatherSceneResolver.resolve(from: response))
    }
}
