import XCTest
@testable import WeatherCore

final class TemperatureGraphGeometryTests: XCTestCase {
    func test_hourlyForecastGrouper_normalisesYAxisCorrectly() {
        let list = [
            HourlyForecastItem(dt: 1000, main: MainWeather(temp: 10, feelsLike: 10, tempMin: 10, tempMax: 10, pressure: 1000, seaLevel: nil, grndLevel: nil, humidity: 50), weather: [], clouds: nil, wind: nil, visibility: nil, pop: nil, rain: nil, snow: nil, sys: nil, dtTxt: nil),
            HourlyForecastItem(dt: 10000, main: MainWeather(temp: 20, feelsLike: 20, tempMin: 20, tempMax: 20, pressure: 1000, seaLevel: nil, grndLevel: nil, humidity: 50), weather: [], clouds: nil, wind: nil, visibility: nil, pop: nil, rain: nil, snow: nil, sys: nil, dtTxt: nil)
        ]
        
        let forecast = ForecastResponse(cod: "200", message: nil, cnt: 2, list: list, city: ForecastCity(id: 1, name: "City", coord: Coordinate(lat: 0, lon: 0), country: "DE", population: nil, timezone: 0, sunrise: nil, sunset: nil))
        
        let (items, _, _) = HourlyForecastGrouper.process(forecast: forecast)
        
        XCTAssertEqual(items.count, 2)
        XCTAssertEqual(items[0].temperatureDotY, 1.0)
        XCTAssertEqual(items[1].temperatureDotY, 0.0)
    }
}
