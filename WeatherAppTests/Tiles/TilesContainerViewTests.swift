import XCTest
import WeatherCore
@testable import WeatherApp

@MainActor
final class TilesContainerViewTests: XCTestCase {
    func test_configure_createsOneViewPerTile() {
        let sut = TilesContainerView(frame: CGRect(x: 0, y: 0, width: 390, height: 400))
        let tiles = [
            TileDisplayItem(id: "a", title: "Humidity", value: "50%", subtitle: nil, tileSize: .standard),
            TileDisplayItem(id: "b", title: "Wind", value: "3 m/s", subtitle: "N", tileSize: .wide)
        ]

        sut.configure(with: tiles)

        XCTAssertEqual(sut.subviews.count, 2)
        XCTAssertGreaterThan(sut.intrinsicContentSize.height, 0)
    }

    func test_layoutSubviews_appliesCalculatorFrames() {
        let sut = TilesContainerView(frame: CGRect(x: 0, y: 0, width: 390, height: 400))
        sut.configure(with: [
            TileDisplayItem(id: "a", title: "A", value: "1", subtitle: nil, tileSize: .standard),
            TileDisplayItem(id: "b", title: "B", value: "2", subtitle: nil, tileSize: .standard)
        ])

        sut.layoutIfNeeded()

        XCTAssertFalse(sut.subviews.isEmpty)
        XCTAssertNotEqual(sut.subviews.first?.frame, .zero)
    }

    func test_compactWidth_showsFewerTilesThanLargeWidth() {
        let tiles = TileKind.allCases.map {
            TileDisplayItem(id: $0.rawValue, title: $0.rawValue, value: "1", subtitle: nil, tileSize: .standard)
        }

        let compact = TilesContainerView(frame: CGRect(x: 0, y: 0, width: 390, height: 400))
        compact.configure(with: tiles)
        compact.layoutIfNeeded()

        let large = TilesContainerView(frame: CGRect(x: 0, y: 0, width: 1024, height: 400))
        large.configure(with: tiles)
        large.layoutIfNeeded()

        XCTAssertLessThan(compact.subviews.count, large.subviews.count)
        XCTAssertEqual(compact.subviews.count, 6)
        XCTAssertEqual(large.subviews.count, TileKind.allCases.count)
    }
}
