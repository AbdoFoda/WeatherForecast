import XCTest
@testable import WeatherCore

final class TileOrderStoreTests: XCTestCase {
    private let suiteName = "TileOrderStoreTests"

    override func setUp() {
        super.setUp()
        UserDefaults(suiteName: suiteName)?.removePersistentDomain(forName: suiteName)
    }

    func test_loadOrder_defaultsToAllCases() {
        let sut = TileOrderStore(defaultsSuiteName: suiteName)
        XCTAssertEqual(sut.loadOrder(), TileKind.allCases)
    }

    func test_saveAndLoadOrder_roundTrip() {
        let sut = TileOrderStore(defaultsSuiteName: suiteName)
        let custom: [TileKind] = [.wind, .humidity, .feelsLike, .pressure, .visibility, .sun, .air, .clouds, .fiveDay, .precipitation]

        sut.saveOrder(custom)

        XCTAssertEqual(sut.loadOrder(), custom)
    }

    func test_loadOrder_appendsMissingKindsFromFutureRelease() {
        let sut = TileOrderStore(defaultsSuiteName: suiteName)
        sut.saveOrder([.wind, .humidity, .feelsLike])

        let loaded = sut.loadOrder()

        XCTAssertEqual(loaded.prefix(3), [.wind, .humidity, .feelsLike])
        XCTAssertTrue(loaded.contains(.precipitation))
        XCTAssertEqual(loaded.count, TileKind.allCases.count)
    }
}
