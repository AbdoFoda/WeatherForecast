import UIKit
import WeatherCore

final class TilesContainerView: UIView {
    private var allTileItems: [TileDisplayItem] = []
    private var visibleTileItems: [TileDisplayItem] = []
    private var tileViews: [WeatherTileView] = []
    private var appliedSizeClass: TileLayoutSizeClass?

    override var intrinsicContentSize: CGSize {
        let width = bounds.width > 0 ? bounds.width : UIScreen.main.bounds.width
        let visible = TileVisibilityPolicy.visibleTiles(from: allTileItems, containerWidth: width)
        let input = TileLayoutCalculator.Input(
            containerSize: CGSize(width: width, height: .greatestFiniteMagnitude),
            tiles: visible,
            horizontalPadding: WeatherDesignSystem.Tile.gridSpacing,
            verticalPadding: WeatherDesignSystem.Tile.gridSpacing,
            spacing: WeatherDesignSystem.Tile.gridSpacing
        )
        let output = TileLayoutCalculator.calculate(input: input)
        return CGSize(width: UIView.noIntrinsicMetric, height: output.totalHeight)
    }

    func configure(with items: [TileDisplayItem]) {
        allTileItems = items
        let width = bounds.width > 0 ? bounds.width : UIScreen.main.bounds.width
        syncVisibleTiles(for: width)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        syncVisibleTiles(for: bounds.width)

        let input = TileLayoutCalculator.Input(
            containerSize: bounds.size,
            tiles: visibleTileItems,
            horizontalPadding: WeatherDesignSystem.Tile.gridSpacing,
            verticalPadding: WeatherDesignSystem.Tile.gridSpacing,
            spacing: WeatherDesignSystem.Tile.gridSpacing
        )

        let output = TileLayoutCalculator.calculate(input: input)

        for (index, frame) in output.frames.enumerated() {
            guard index < tileViews.count else { break }
            tileViews[index].frame = frame
        }
    }

    private func syncVisibleTiles(for width: CGFloat) {
        let effectiveWidth = width > 0 ? width : UIScreen.main.bounds.width
        let sizeClass = TileLayoutSizeClass.from(containerWidth: effectiveWidth)
        let visible = TileVisibilityPolicy.visibleTiles(
            from: allTileItems,
            containerWidth: effectiveWidth
        )

        let idsChanged = visible.map(\.id) != visibleTileItems.map(\.id)
        let sizeClassChanged = sizeClass != appliedSizeClass
        guard idsChanged || sizeClassChanged else { return }

        visibleTileItems = visible
        appliedSizeClass = sizeClass
        rebuildTileViews()
    }

    private func rebuildTileViews() {
        tileViews.forEach { $0.removeFromSuperview() }
        tileViews.removeAll()

        for item in visibleTileItems {
            let view = WeatherTileView()
            view.configure(with: item)
            addSubview(view)
            tileViews.append(view)
        }

        invalidateIntrinsicContentSize()
    }
}
