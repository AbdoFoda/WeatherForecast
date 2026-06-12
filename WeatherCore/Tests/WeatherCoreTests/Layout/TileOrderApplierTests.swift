import XCTest
@testable import WeatherCore

final class TileOrderApplierTests: XCTestCase {
    func test_apply_sortsTilesByStoredOrder() {
        let tiles = [
            makeTile(.humidity),
            makeTile(.feelsLike),
            makeTile(.wind),
        ]
        let order: [TileKind] = [.wind, .feelsLike, .humidity]

        let result = TileOrderApplier.apply(order: order, to: tiles)

        XCTAssertEqual(result.map(\.id), order.map(\.rawValue))
    }

    func test_apply_appendsUnknownTilesAtEnd() {
        let tiles = [makeTile(.wind), makeTile(.humidity)]
        let order: [TileKind] = [.humidity]

        let result = TileOrderApplier.apply(order: order, to: tiles)

        XCTAssertEqual(result.map(\.id), [TileKind.humidity.rawValue, TileKind.wind.rawValue])
    }

    func test_reorder_movingVisibleTile_preservesHiddenPositions() {
        let order: [TileKind] = [
            .feelsLike, .humidity, .wind, .pressure, .visibility, .sun, .air, .clouds, .fiveDay, .precipitation,
        ]
        let visible: [TileKind] = [.feelsLike, .humidity, .wind, .pressure, .sun, .air]

        let result = TileOrderApplier.reorder(
            order: order,
            moving: .wind,
            toVisibleIndex: 0,
            visibleKinds: visible
        )

        XCTAssertEqual(
            result,
            [.wind, .feelsLike, .humidity, .pressure, .visibility, .sun, .air, .clouds, .fiveDay, .precipitation]
        )
    }

    func test_reorder_noOpWhenKindMissingFromVisibleSet() {
        let order = TileKind.allCases
        let visible: [TileKind] = [.feelsLike, .humidity, .wind]

        let result = TileOrderApplier.reorder(
            order: order,
            moving: .precipitation,
            toVisibleIndex: 0,
            visibleKinds: visible
        )

        XCTAssertEqual(result, order)
    }

    private func makeTile(_ kind: TileKind) -> TileDisplayItem {
        TileDisplayItem(
            id: kind.rawValue,
            title: kind.rawValue,
            value: "1",
            subtitle: nil,
            tileSize: .standard
        )
    }
}
