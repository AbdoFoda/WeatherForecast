import XCTest
import CoreGraphics
@testable import WeatherCore

final class TemperatureGraphGeometryTests: XCTestCase {
    func test_hourlyForecastGrouper_normalisesYAxisCorrectly() {
        let list = [
            sampleItem(dt: 1000, temp: 10),
            sampleItem(dt: 10000, temp: 20)
        ]

        let forecast = makeForecast(list: list)

        let items = HourlyForecastGrouper.process(forecast: forecast).items

        XCTAssertEqual(items.count, 2)
        XCTAssertEqual(items[0].temperatureDotY, 1.0)
        XCTAssertEqual(items[1].temperatureDotY, 0.0)
    }

    func test_normalizedDotY_mapsMinToOneAndMaxToZero() {
        XCTAssertEqual(TemperatureGraphGeometry.normalizedDotY(temperature: 10, minTemp: 10, maxTemp: 20), 1.0)
        XCTAssertEqual(TemperatureGraphGeometry.normalizedDotY(temperature: 20, minTemp: 10, maxTemp: 20), 0.0)
        XCTAssertEqual(
            TemperatureGraphGeometry.normalizedDotY(temperature: 15, minTemp: 10, maxTemp: 20),
            0.5,
            accuracy: 0.001
        )
    }

    func test_bezierControlPoints_usesCatmullRomConversion() {
        let p0 = CGPoint(x: 0, y: 10)
        let p1 = CGPoint(x: 10, y: 20)
        let p2 = CGPoint(x: 20, y: 10)
        let p3 = CGPoint(x: 30, y: 20)

        let (cp1, cp2) = TemperatureGraphGeometry.bezierControlPoints(p0: p0, p1: p1, p2: p2, p3: p3)

        XCTAssertEqual(cp1.x, 10 + (20 - 0) / 6.0, accuracy: 0.001)
        XCTAssertEqual(cp2.x, 20 - (30 - 10) / 6.0, accuracy: 0.001)
    }

    func test_groupByDay_groupsConsecutiveItems() {
        let list = [
            sampleItem(dt: 1_718_000_000, temp: 18),
            sampleItem(dt: 1_718_010_800, temp: 19),
            sampleItem(dt: 1_718_086_400, temp: 17)
        ]
        let forecast = makeForecast(list: list, timezone: 7_200)

        let groups = HourlyForecastGrouper.groupByDay(forecast: forecast)
        XCTAssertEqual(groups.count, 2)
        XCTAssertEqual(groups[0].count, 2)
        XCTAssertEqual(groups[1].count, 1)
    }

    func test_todayTemperatureRange_usesForecastSlotsForCurrentDay() {
        let tzOffset: TimeInterval = 7_200
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        let dayKey = formatter.string(from: Date().addingTimeInterval(tzOffset))

        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let base = formatter.date(from: "\(dayKey) 02:00:00")!.timeIntervalSince1970 - tzOffset

        let list = [
            sampleItem(dt: base, temp: 12),
            sampleItem(dt: base + 10_800, temp: 21),
            sampleItem(dt: base + 86_400, temp: 9)
        ]
        let forecast = makeForecast(list: list, timezone: 7_200)

        let range = HourlyForecastGrouper.todayTemperatureRange(forecast: forecast)
        XCTAssertEqual(range?.min, 12)
        XCTAssertEqual(range?.max, 21)
    }

    private func sampleMain(temp: Double) -> MainWeather {
        MainWeather(
            temp: temp,
            feelsLike: temp,
            tempMin: temp,
            tempMax: temp,
            pressure: 1013,
            seaLevel: nil,
            grndLevel: nil,
            humidity: 50
        )
    }

    private func sampleItem(dt: TimeInterval, temp: Double) -> HourlyForecastItem {
        HourlyForecastItem(
            dt: dt,
            main: sampleMain(temp: temp),
            weather: [],
            clouds: nil,
            wind: nil,
            visibility: nil,
            pop: nil,
            rain: nil,
            snow: nil,
            sys: nil,
            dtTxt: nil
        )
    }

    private func makeForecast(list: [HourlyForecastItem], timezone: Int = 0) -> ForecastResponse {
        ForecastResponse(
            cod: "200",
            message: nil,
            cnt: list.count,
            list: list,
            city: ForecastCity(
                id: 1,
                name: "City",
                coord: Coordinate(lat: 52.52, lon: 13.4),
                country: "DE",
                population: nil,
                timezone: timezone,
                sunrise: nil,
                sunset: nil
            )
        )
    }
}
