import XCTest
import WeatherCore
@testable import WeatherApp

final class WeatherBackgroundPaletteTests: XCTestCase {
    func test_colors_clearDay_differsFromClearNight() {
        let day = WeatherBackgroundPalette.colors(for: .clearDay)
        let night = WeatherBackgroundPalette.colors(for: .clearNight)
        XCTAssertNotEqual(day.top, night.top)
        XCTAssertNotEqual(day.bottom, night.bottom)
    }

    func test_colors_rain_isDarkerThanClearDay() {
        let rain = WeatherBackgroundPalette.colors(for: .rain)
        let clear = WeatherBackgroundPalette.colors(for: .clearDay)
        var rainBrightness: CGFloat = 0
        var clearBrightness: CGFloat = 0
        rain.top.getHue(nil, saturation: nil, brightness: &rainBrightness, alpha: nil)
        clear.top.getHue(nil, saturation: nil, brightness: &clearBrightness, alpha: nil)
        XCTAssertLessThan(rainBrightness, clearBrightness)
    }
}
