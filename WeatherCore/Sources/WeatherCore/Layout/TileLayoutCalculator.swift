import Foundation
import CoreGraphics

public struct TileLayoutCalculator {
    public struct Input {
        public let containerSize: CGSize
        public let tiles: [TileDisplayItem]
        public let horizontalPadding: CGFloat
        public let verticalPadding: CGFloat
        public let spacing: CGFloat
        
        public init(containerSize: CGSize, tiles: [TileDisplayItem], horizontalPadding: CGFloat, verticalPadding: CGFloat, spacing: CGFloat) {
            self.containerSize = containerSize
            self.tiles = tiles
            self.horizontalPadding = horizontalPadding
            self.verticalPadding = verticalPadding
            self.spacing = spacing
        }
    }
    
    public struct Output {
        public let frames: [CGRect]
        public let totalHeight: CGFloat
    }
    
    public static func calculate(input: Input) -> Output {
        guard !input.tiles.isEmpty else { return Output(frames: [], totalHeight: 0) }
        
        var columns = WeatherConstants.TileLayout.phoneColumnCount
        if input.containerSize.width >= WeatherConstants.TileLayout.largeTabletMinWidth {
            columns = WeatherConstants.TileLayout.largeTabletColumnCount
        } else if input.containerSize.width >= WeatherConstants.TileLayout.tabletMinWidth {
            columns = WeatherConstants.TileLayout.tabletColumnCount
        }

        let availableWidth = input.containerSize.width - (input.horizontalPadding * 2) - (input.spacing * CGFloat(columns - 1))
        let colWidth = max(0, availableWidth / CGFloat(columns))
        let rowHeight = WeatherConstants.TileLayout.rowHeight
        
        var frames: [CGRect] = []
        
        var grid: [Int: [Int: Bool]] = [:] 
        
        func isOccupied(row: Int, col: Int) -> Bool {
            grid[row]?[col] == true
        }
        
        func markOccupied(row: Int, col: Int) {
            if grid[row] == nil { grid[row] = [:] }
            grid[row]?[col] = true
        }
        
        for tile in input.tiles {
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
                        let x = input.horizontalPadding + (CGFloat(searchCol) * (colWidth + input.spacing))
                        let y = input.verticalPadding + (CGFloat(searchRow) * (rowHeight + input.spacing))
                        let w = (CGFloat(colsNeeded) * colWidth) + (CGFloat(colsNeeded - 1) * input.spacing)
                        let h = (CGFloat(rowsNeeded) * rowHeight) + (CGFloat(rowsNeeded - 1) * input.spacing)
                        
                        frames.append(CGRect(x: x, y: y, width: w, height: h))
                        
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
        
        let maxRow = grid.keys.max() ?? 0
        let totalHeight = input.verticalPadding * 2 + CGFloat(maxRow + 1) * rowHeight + CGFloat(maxRow) * input.spacing
        
        return Output(frames: frames, totalHeight: totalHeight)
    }
}
