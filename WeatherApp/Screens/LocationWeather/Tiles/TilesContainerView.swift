import UIKit
import WeatherCore

final class TilesContainerView: UIView {
    var onOrderChanged: (([TileKind]) -> Void)?
    var onDragStateChanged: ((Bool) -> Void)?
    var onTileMenuRequested: ((TileKind, UIView) -> Void)?
    var layoutTargetHeight: CGFloat = 0

    var currentTileIDs: Set<String> {
        Set(allTileItems.map(\.id))
    }

    private var allTileItems: [TileDisplayItem] = []
    private var visibleTileItems: [TileDisplayItem] = []
    private var tileViews: [WeatherTileView] = []
    private var layoutFrames: [CGRect] = []
    private var appliedSizeClass: TileLayoutSizeClass?

    private var dragOriginalVisibleIndex: Int?
    private var dragDestinationVisibleIndex: Int?
    private var draggedKind: TileKind?
    private var draggedTileView: WeatherTileView?
    private var dragStartLocation: CGPoint?
    private var dragDidMove = false
    private var dragSnapshotItems: [TileDisplayItem] = []
    private var dragSnapshotViews: [WeatherTileView] = []

    private struct LayoutCacheKey: Equatable {
        let width: CGFloat
        let targetHeight: CGFloat
        let ids: [String]
        let dragging: Bool
    }
    private var layoutCache: (key: LayoutCacheKey, output: TileLayoutCalculator.Output)?
    private var lastNonZeroWidth: CGFloat = 0

    private static let fallbackWidth: CGFloat = 320

    private func resolvedWidth(_ width: CGFloat) -> CGFloat {
        if width > 0 {
            lastNonZeroWidth = width
            return width
        }
        if lastNonZeroWidth > 0 {
            return lastNonZeroWidth
        }
        return window?.windowScene?.screen.bounds.width ?? Self.fallbackWidth
    }

    override var intrinsicContentSize: CGSize {
        let output = layoutOutput(forWidth: resolvedWidth(bounds.width))
        return CGSize(width: UIView.noIntrinsicMetric, height: output.totalHeight)
    }

    func configure(with items: [TileDisplayItem]) {
        guard draggedTileView == nil else { return }
        allTileItems = items
        syncVisibleTiles(for: resolvedWidth(bounds.width))
        refreshVisibleTileContent()
    }

    func prepareForContainerSizeChange() {
        appliedSizeClass = nil
        layoutCache = nil
        invalidateIntrinsicContentSize()
    }

    private func refreshVisibleTileContent() {
        let itemsByID = allTileItems.reduce(into: [String: TileDisplayItem]()) { result, item in
            if result[item.id] == nil { result[item.id] = item }
        }
        for (index, view) in tileViews.enumerated() {
            guard visibleTileItems.indices.contains(index),
                  let updated = itemsByID[visibleTileItems[index].id] else { continue }
            visibleTileItems[index] = updated
            view.configure(with: updated)
            view.accessibilityLabel = updated.title
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        syncVisibleTiles(for: bounds.width)
        applyLayout(animated: false)
    }

    private func syncVisibleTiles(for width: CGFloat) {
        guard draggedTileView == nil else { return }

        let effectiveWidth = resolvedWidth(width)
        let sizeClass = TileLayoutSizeClass.from(containerWidth: effectiveWidth)
        let visible = TileVisibilityPolicy.visibleTiles(
            from: allTileItems,
            containerWidth: effectiveWidth
        )

        let visibleIDs = Set(visible.map(\.id))
        let currentIDs = Set(visibleTileItems.map(\.id))
        let idsChanged = visibleIDs != currentIDs
        let sizeClassChanged = sizeClass != appliedSizeClass
        guard idsChanged || sizeClassChanged else { return }

        visibleTileItems = visible
        appliedSizeClass = sizeClass
        rebuildTileViews()
    }

    private func rebuildTileViews() {
        layoutCache = nil
        tileViews.forEach { $0.removeFromSuperview() }
        tileViews.removeAll()

        for item in visibleTileItems {
            let view = WeatherTileView()
            view.configure(with: item)
            view.tileKind = TileKind(rawValue: item.id)
            view.isAccessibilityElement = true
            view.accessibilityLabel = item.title
            view.accessibilityHint = L10n.Tiles.reorderHint

            let longPress = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
            longPress.minimumPressDuration = 0.35
            longPress.cancelsTouchesInView = false
            longPress.delegate = self
            view.addGestureRecognizer(longPress)

            addSubview(view)
            tileViews.append(view)
        }

        invalidateIntrinsicContentSize()
    }

    private func applyLayout(animated: Bool) {
        let output = layoutOutput(forWidth: bounds.width)
        layoutFrames = output.frames

        let updates = {
            for (index, frame) in output.frames.enumerated() {
                guard index < self.tileViews.count else { break }
                let view = self.tileViews[index]
                guard view !== self.draggedTileView else { continue }
                view.frame = frame
            }
        }

        if animated {
            UIView.animate(withDuration: 0.2, animations: updates)
        } else {
            updates()
        }
    }

}

extension TilesContainerView {
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard let tileView = gesture.view as? WeatherTileView,
              let sourceIndex = tileViews.firstIndex(of: tileView) else { return }

        switch gesture.state {
        case .began:
            dragStartLocation = gesture.location(in: self)
            dragDidMove = false
            beginDragging(tileView: tileView, sourceIndex: sourceIndex)
        case .changed:
            let location = gesture.location(in: self)
            if let start = dragStartLocation,
               hypot(location.x - start.x, location.y - start.y) > 8 {
                dragDidMove = true
            }
            updateDragging(to: location)
        case .ended:
            finishDragging()
        case .cancelled, .failed:
            cancelDragging()
        default:
            break
        }
    }

    private func beginDragging(tileView: WeatherTileView, sourceIndex: Int) {
        dragOriginalVisibleIndex = sourceIndex
        dragDestinationVisibleIndex = sourceIndex
        draggedKind = tileView.tileKind
        draggedTileView = tileView
        dragSnapshotItems = visibleTileItems
        dragSnapshotViews = tileViews

        applyLayout(animated: false)

        tileView.layer.zPosition = 1
        tileView.transform = CGAffineTransform(scaleX: 1.04, y: 1.04)
        tileView.layer.shadowColor = UIColor.black.cgColor
        tileView.layer.shadowOpacity = 0.18
        tileView.layer.shadowRadius = 10
        tileView.layer.shadowOffset = CGSize(width: 0, height: 4)
        tileView.layer.masksToBounds = false

        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
        onDragStateChanged?(true)
    }

    private func updateDragging(to location: CGPoint) {
        guard let draggedTileView else { return }

        draggedTileView.center = location

        let destination = destinationVisibleIndex(for: location)
        guard destination != dragDestinationVisibleIndex else { return }

        dragDestinationVisibleIndex = destination
        previewReorder(to: destination)
    }

    private func finishDragging() {
        defer { cleanupDragState() }

        if !dragDidMove, let kind = draggedKind, let view = draggedTileView {
            onTileMenuRequested?(kind, view)
            return
        }

        guard let kind = draggedKind,
              let originalSource = dragOriginalVisibleIndex,
              let destination = dragDestinationVisibleIndex,
              originalSource != destination else {
            return
        }

        let visibleKinds = TileOrderApplier.visibleKinds(from: allTileItems, containerWidth: bounds.width)
        let currentOrder = TileOrderApplier.order(from: allTileItems)
        let newOrder = TileOrderApplier.reorder(
            order: currentOrder,
            moving: kind,
            toVisibleIndex: destination,
            visibleKinds: visibleKinds
        )

        allTileItems = TileOrderApplier.apply(order: newOrder, to: allTileItems)
        visibleTileItems = TileVisibilityPolicy.visibleTiles(
            from: allTileItems,
            containerWidth: bounds.width
        )
        onOrderChanged?(newOrder)
    }

    private func cancelDragging() {
        if !dragSnapshotItems.isEmpty {
            visibleTileItems = dragSnapshotItems
            tileViews = dragSnapshotViews
        }
        cleanupDragState()
    }

    private func cleanupDragState() {
        if let draggedTileView {
            draggedTileView.transform = .identity
            draggedTileView.layer.shadowOpacity = 0
            draggedTileView.layer.zPosition = 0
        }

        draggedTileView = nil
        dragOriginalVisibleIndex = nil
        dragDestinationVisibleIndex = nil
        draggedKind = nil
        dragStartLocation = nil
        dragDidMove = false
        dragSnapshotItems = []
        dragSnapshotViews = []
        onDragStateChanged?(false)
        applyLayout(animated: true)
    }

    private func previewReorder(to destination: Int) {
        guard let source = tileViews.firstIndex(where: { $0 === draggedTileView }),
              source != destination,
              visibleTileItems.indices.contains(source),
              visibleTileItems.indices.contains(destination) else { return }

        var previewItems = visibleTileItems
        let item = previewItems.remove(at: source)
        previewItems.insert(item, at: destination)
        visibleTileItems = previewItems

        var previewViews = tileViews
        let view = previewViews.remove(at: source)
        previewViews.insert(view, at: destination)
        tileViews = previewViews

        applyLayout(animated: true)
    }

    private func destinationVisibleIndex(for location: CGPoint) -> Int {
        guard !layoutFrames.isEmpty else { return 0 }

        var bestIndex = 0
        var bestDistance = CGFloat.greatestFiniteMagnitude

        for (index, frame) in layoutFrames.enumerated() {
            let distance = hypot(location.x - frame.midX, location.y - frame.midY)
            if distance < bestDistance {
                bestDistance = distance
                bestIndex = index
            }
        }

        return bestIndex
    }

    private func layoutOutput(forWidth width: CGFloat) -> TileLayoutCalculator.Output {
        let effectiveWidth = resolvedWidth(width)
        let dragging = draggedTileView != nil
        let tiles = dragging
            ? visibleTileItems
            : TileVisibilityPolicy.visibleTiles(from: allTileItems, containerWidth: effectiveWidth)

        let key = LayoutCacheKey(
            width: effectiveWidth,
            targetHeight: layoutTargetHeight,
            ids: tiles.map(\.id),
            dragging: dragging
        )
        if let layoutCache, layoutCache.key == key {
            return layoutCache.output
        }

        let targetHeight = layoutTargetHeight > 0 ? layoutTargetHeight : nil
        let input = TileLayoutCalculator.Input(
            containerSize: CGSize(width: effectiveWidth, height: layoutTargetHeight),
            tiles: tiles,
            horizontalPadding: WeatherDesignSystem.Tile.gridSpacing,
            verticalPadding: WeatherDesignSystem.Tile.gridSpacing,
            spacing: WeatherDesignSystem.Tile.gridSpacing,
            targetTotalHeight: targetHeight
        )
        let output = TileLayoutCalculator.calculate(input: input)
        layoutCache = (key, output)
        return output
    }
}

extension TilesContainerView: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer
    ) -> Bool {
        true
    }
}
