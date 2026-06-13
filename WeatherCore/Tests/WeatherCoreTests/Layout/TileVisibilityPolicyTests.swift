import XCTest
@testable import WeatherCore

final class TileVisibilityPolicyTests: XCTestCase {
    private var allTiles: [TileDisplayItem] {
        [
            makeTile(.feelsLike),
            makeTile(.humidity),
            makeTile(.wind),
            makeTile(.pressure),
            makeTile(.visibility),
            makeTile(.sun),
            makeTile(.air, size: .wide),
            makeTile(.clouds),
            makeTile(.fiveDay, size: .wide),
            makeTile(.precipitation)
        ]
    }

    func test_compactWidth_showsCoreTilesOnly() {
        let visible = TileVisibilityPolicy.visibleTiles(from: allTiles, containerWidth: 390)

        XCTAssertEqual(visible.count, 6)
        XCTAssertEqual(visible.map(\.id), [
            TileKind.feelsLike.rawValue,
            TileKind.humidity.rawValue,
            TileKind.wind.rawValue,
            TileKind.pressure.rawValue,
            TileKind.sun.rawValue,
            TileKind.air.rawValue
        ])
    }

    func test_regularWidth_addsSecondaryTiles() {
        let visible = TileVisibilityPolicy.visibleTiles(from: allTiles, containerWidth: 600)

        XCTAssertEqual(visible.count, 8)
        XCTAssertTrue(visible.contains(where: { $0.id == TileKind.visibility.rawValue }))
        XCTAssertTrue(visible.contains(where: { $0.id == TileKind.clouds.rawValue }))
        XCTAssertFalse(visible.contains(where: { $0.id == TileKind.fiveDay.rawValue }))
    }

    func test_largeWidth_showsAllTiles() {
        let visible = TileVisibilityPolicy.visibleTiles(from: allTiles, containerWidth: 1024)

        XCTAssertEqual(visible.count, allTiles.count)
    }

    func test_layoutSizeClass_boundaries() {
        XCTAssertEqual(TileLayoutSizeClass.from(containerWidth: 390), .compact)
        XCTAssertEqual(TileLayoutSizeClass.from(containerWidth: 500), .regular)
        XCTAssertEqual(TileLayoutSizeClass.from(containerWidth: 800), .large)
    }

    private func makeTile(_ kind: TileKind, size: TileDisplayItem.TileSize = .standard) -> TileDisplayItem {
        TileDisplayItem(
            id: kind.rawValue,
            title: kind.rawValue,
            value: "—",
            subtitle: nil,
            tileSize: size
        )
    }
}
