import Foundation
import CoreGraphics

public struct TileLayoutCalculator {
    public struct Input {
        public let containerSize: CGSize
        public let tiles: [TileDisplayItem]
        public let horizontalPadding: CGFloat
        public let verticalPadding: CGFloat
        public let spacing: CGFloat
        public let targetTotalHeight: CGFloat?
        public let minRowHeight: CGFloat

        public init(
            containerSize: CGSize,
            tiles: [TileDisplayItem],
            horizontalPadding: CGFloat,
            verticalPadding: CGFloat,
            spacing: CGFloat,
            targetTotalHeight: CGFloat? = nil,
            minRowHeight: CGFloat = WeatherConstants.TileLayout.rowHeight
        ) {
            self.containerSize = containerSize
            self.tiles = tiles
            self.horizontalPadding = horizontalPadding
            self.verticalPadding = verticalPadding
            self.spacing = spacing
            self.targetTotalHeight = targetTotalHeight
            self.minRowHeight = minRowHeight
        }
    }

    public struct Output {
        public let frames: [CGRect]
        public let totalHeight: CGFloat
        public let rowHeight: CGFloat
    }

    private struct Placement {
        let row: Int
        let col: Int
        let colsNeeded: Int
        let rowsNeeded: Int
    }

    public static func calculate(input: Input) -> Output {
        guard !input.tiles.isEmpty else {
            return Output(frames: [], totalHeight: 0, rowHeight: input.minRowHeight)
        }

        let columns = columnCount(for: input.containerSize.width)
        let availableWidth = input.containerSize.width
            - (input.horizontalPadding * 2)
            - (input.spacing * CGFloat(columns - 1))
        let colWidth = max(0, availableWidth / CGFloat(columns))

        let placements = packTiles(input.tiles, columns: columns)
        let maxRow = placements.map { $0.row + $0.rowsNeeded - 1 }.max() ?? 0
        let rowCount = maxRow + 1
        let rowHeight = resolvedRowHeight(
            input: input,
            maxRow: maxRow,
            rowCount: rowCount
        )

        let frames = placements.map { placement in
            let x = input.horizontalPadding + (CGFloat(placement.col) * (colWidth + input.spacing))
            let y = input.verticalPadding + (CGFloat(placement.row) * (rowHeight + input.spacing))
            let w = (CGFloat(placement.colsNeeded) * colWidth)
                + (CGFloat(placement.colsNeeded - 1) * input.spacing)
            let h = (CGFloat(placement.rowsNeeded) * rowHeight)
                + (CGFloat(placement.rowsNeeded - 1) * input.spacing)
            return CGRect(x: x, y: y, width: w, height: h)
        }

        let totalHeight = input.verticalPadding * 2
            + CGFloat(rowCount) * rowHeight
            + CGFloat(maxRow) * input.spacing

        return Output(frames: frames, totalHeight: totalHeight, rowHeight: rowHeight)
    }

    private static func columnCount(for width: CGFloat) -> Int {
        if width >= WeatherConstants.TileLayout.largeTabletMinWidth {
            return WeatherConstants.TileLayout.largeTabletColumnCount
        }
        if width >= WeatherConstants.TileLayout.tabletMinWidth {
            return WeatherConstants.TileLayout.tabletColumnCount
        }
        return WeatherConstants.TileLayout.phoneColumnCount
    }

    private static func resolvedRowHeight(
        input: Input,
        maxRow: Int,
        rowCount: Int
    ) -> CGFloat {
        let fixedOverhead = input.verticalPadding * 2 + CGFloat(maxRow) * input.spacing
        let naturalHeight = fixedOverhead + CGFloat(rowCount) * input.minRowHeight

        guard let target = input.targetTotalHeight, target >= naturalHeight else {
            return input.minRowHeight
        }

        let expandableHeight = target - fixedOverhead
        return expandableHeight / CGFloat(rowCount)
    }

    private static func packTiles(_ tiles: [TileDisplayItem], columns: Int) -> [Placement] {
        var placements: [Placement] = []
        var grid: [Int: [Int: Bool]] = [:]

        func isOccupied(row: Int, col: Int) -> Bool {
            grid[row]?[col] == true
        }

        func markOccupied(row: Int, col: Int) {
            if grid[row] == nil { grid[row] = [:] }
            grid[row]?[col] = true
        }

        for tile in tiles {
            let colsNeeded = tile.tileSize == .wide ? 2 : 1
            let rowsNeeded = tile.tileSize == .tall ? 2 : 1

            var foundPos = false
            var searchRow = 0

            while !foundPos {
                for searchCol in 0...(columns - colsNeeded) {
                    var spaceFree = true
                    for r in searchRow..<(searchRow + rowsNeeded) {
                        for c in searchCol..<(searchCol + colsNeeded) {
                            if isOccupied(row: r, col: c) {
                                spaceFree = false
                            }
                        }
                    }

                    if spaceFree {
                        placements.append(
                            Placement(
                                row: searchRow,
                                col: searchCol,
                                colsNeeded: colsNeeded,
                                rowsNeeded: rowsNeeded
                            )
                        )

                        for r in searchRow..<(searchRow + rowsNeeded) {
                            for c in searchCol..<(searchCol + colsNeeded) {
                                markOccupied(row: r, col: c)
                            }
                        }

                        foundPos = true
                        break
                    }
                }
                if !foundPos {
                    searchRow += 1
                }
            }
        }

        return placements
    }
}
