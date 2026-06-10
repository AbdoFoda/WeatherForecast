import XCTest
import WeatherCore
@testable import WeatherApp

@MainActor
final class WeatherBackgroundViewTests: XCTestCase {
    func test_configure_appliesGradientLayers() {
        let sut = WeatherBackgroundView(frame: CGRect(x: 0, y: 0, width: 320, height: 640))
        sut.layoutIfNeeded()

        sut.configure(scene: .rain)

        XCTAssertEqual(sut.layer.sublayers?.count, 2)
    }

    func test_configure_sameSceneIsNoOp() {
        let sut = WeatherBackgroundView(frame: CGRect(x: 0, y: 0, width: 320, height: 640))
        sut.configure(scene: .clearDay)
        let layerCountAfterFirst = sut.layer.sublayers?.count
        sut.configure(scene: .clearDay)
        XCTAssertEqual(sut.layer.sublayers?.count, layerCountAfterFirst)
    }
}
