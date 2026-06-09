import XCTest
@testable import WeatherCore

final class TileLayoutCalculatorTests: XCTestCase {
    func test_emptyTiles() {
        let input = TileLayoutCalculator.Input(containerSize: CGSize(width: 400, height: 800), tiles: [], horizontalPadding: 16, verticalPadding: 16, spacing: 10)
        let output = TileLayoutCalculator.calculate(input: input)
        XCTAssertTrue(output.frames.isEmpty)
        XCTAssertEqual(output.totalHeight, 0)
    }
    
    func test_compactSize_twoColumns() {
        let tiles = [
            TileDisplayItem(id: "1", title: "", value: "", subtitle: nil, tileSize: .standard),
            TileDisplayItem(id: "2", title: "", value: "", subtitle: nil, tileSize: .standard)
        ]
        let input = TileLayoutCalculator.Input(containerSize: CGSize(width: 400, height: 800), tiles: tiles, horizontalPadding: 10, verticalPadding: 10, spacing: 10)
        let output = TileLayoutCalculator.calculate(input: input)
        
        XCTAssertEqual(output.frames.count, 2)
        XCTAssertEqual(output.frames[0].minY, 10)
        XCTAssertEqual(output.frames[1].minY, 10)
        XCTAssertEqual(output.frames[0].minX, 10)
        XCTAssertEqual(output.frames[1].minX, 10 + 185 + 10)
    }
    
    func test_wideTile_takesTwoColumns() {
        let tiles = [
            TileDisplayItem(id: "1", title: "", value: "", subtitle: nil, tileSize: .wide),
            TileDisplayItem(id: "2", title: "", value: "", subtitle: nil, tileSize: .standard)
        ]
        let input = TileLayoutCalculator.Input(containerSize: CGSize(width: 400, height: 800), tiles: tiles, horizontalPadding: 10, verticalPadding: 10, spacing: 10)
        let output = TileLayoutCalculator.calculate(input: input)
        
        XCTAssertEqual(output.frames[0].width, 380)
        XCTAssertEqual(output.frames[1].minY, 10 + 120 + 10)
    }
}
