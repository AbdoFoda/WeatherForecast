import UIKit
import WeatherCore

final class TilesContainerView: UIView {
    private var tileViews: [WeatherTileView] = []
    private var tileItems: [TileDisplayItem] = []
    
    override var intrinsicContentSize: CGSize {
        let input = TileLayoutCalculator.Input(
            containerSize: CGSize(width: bounds.width == 0 ? UIScreen.main.bounds.width : bounds.width, height: .greatestFiniteMagnitude),
            tiles: tileItems,
            horizontalPadding: 16,
            verticalPadding: 16,
            spacing: 16
        )
        let output = TileLayoutCalculator.calculate(input: input)
        return CGSize(width: UIView.noIntrinsicMetric, height: output.totalHeight)
    }
    
    func configure(with items: [TileDisplayItem]) {
        self.tileItems = items
        
        tileViews.forEach { $0.removeFromSuperview() }
        tileViews.removeAll()
        
        for item in items {
            let view = WeatherTileView()
            view.configure(with: item)
            addSubview(view)
            tileViews.append(view)
        }
        
        setNeedsLayout()
        invalidateIntrinsicContentSize()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let input = TileLayoutCalculator.Input(
            containerSize: bounds.size,
            tiles: tileItems,
            horizontalPadding: 16,
            verticalPadding: 16,
            spacing: 16
        )
        
        let output = TileLayoutCalculator.calculate(input: input)
        
        for (index, frame) in output.frames.enumerated() {
            guard index < tileViews.count else { break }
            tileViews[index].frame = frame
        }
    }
}
