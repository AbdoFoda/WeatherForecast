import UIKit

final class TemperatureGraphLayout: UICollectionViewLayout {
    static let dayHeaderKind = "DayHeader"

    var itemWidth: CGFloat = 88
    var cellContentHeight: CGFloat = 160
    var headerBandHeight: CGFloat = 36
    var headerWidth: CGFloat = 110
    var headerHeight: CGFloat = 28
    var dayHeaders: [(itemIndex: Int, label: String)] = []

    private var cache: [UICollectionViewLayoutAttributes] = []
    private var headerCache: [UICollectionViewLayoutAttributes] = []
    private var contentWidth: CGFloat = 0
    private var needsFullRebuild = true

    var totalHeight: CGFloat { headerBandHeight + cellContentHeight }

    override var collectionViewContentSize: CGSize {
        CGSize(width: contentWidth, height: totalHeight)
    }

    override func invalidateLayout(with context: UICollectionViewLayoutInvalidationContext) {
        if context.invalidateEverything || context.invalidateDataSourceCounts {
            needsFullRebuild = true
        }
        super.invalidateLayout(with: context)
    }

    override func prepare() {
        super.prepare()
        guard let collectionView, needsFullRebuild else { return }
        needsFullRebuild = false
        cache.removeAll()
        headerCache.removeAll()

        let itemCount = collectionView.numberOfItems(inSection: 0)
        for item in 0..<itemCount {
            let frame = CGRect(
                x: CGFloat(item) * itemWidth,
                y: headerBandHeight,
                width: itemWidth,
                height: cellContentHeight
            )
            let attributes = UICollectionViewLayoutAttributes(forCellWith: IndexPath(item: item, section: 0))
            attributes.frame = frame
            cache.append(attributes)
        }
        contentWidth = CGFloat(itemCount) * itemWidth

        for header in dayHeaders {
            let x = CGFloat(header.itemIndex) * itemWidth
            let attributes = UICollectionViewLayoutAttributes(
                forSupplementaryViewOfKind: Self.dayHeaderKind,
                with: IndexPath(item: header.itemIndex, section: 0)
            )
            attributes.frame = CGRect(
                x: x,
                y: (headerBandHeight - headerHeight) / 2,
                width: headerWidth,
                height: headerHeight
            )
            attributes.zIndex = 1000
            headerCache.append(attributes)
        }
    }

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        var visible = cache.filter { $0.frame.intersects(rect) }
        for (index, header) in headerCache.enumerated() {
            guard let copy = header.copy() as? UICollectionViewLayoutAttributes else { continue }
            copy.frame = stickyFrame(for: copy, headerIndex: index)
            visible.append(copy)
        }
        return visible
    }

    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard cache.indices.contains(indexPath.item) else { return nil }
        return cache[indexPath.item]
    }

    override func layoutAttributesForSupplementaryView(
        ofKind elementKind: String,
        at indexPath: IndexPath
    ) -> UICollectionViewLayoutAttributes? {
        guard elementKind == Self.dayHeaderKind,
              let headerIndex = dayHeaders.firstIndex(where: { $0.itemIndex == indexPath.item }),
              let copy = headerCache[headerIndex].copy() as? UICollectionViewLayoutAttributes else {
            return nil
        }
        copy.frame = stickyFrame(for: copy, headerIndex: headerIndex)
        return copy
    }

    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        guard let collectionView else { return false }
        if collectionView.bounds.size != newBounds.size {
            needsFullRebuild = true
            return true
        }
        return collectionView.contentOffset.x != newBounds.origin.x
    }

    override func invalidationContext(forBoundsChange newBounds: CGRect) -> UICollectionViewLayoutInvalidationContext {
        let context = super.invalidationContext(forBoundsChange: newBounds)
        guard let collectionView, collectionView.bounds.size == newBounds.size else { return context }

        let headerIndexPaths = headerCache.map(\.indexPath)
        if !headerIndexPaths.isEmpty {
            context.invalidateSupplementaryElements(ofKind: Self.dayHeaderKind, at: headerIndexPaths)
        }
        return context
    }

    private func stickyFrame(
        for attributes: UICollectionViewLayoutAttributes,
        headerIndex: Int
    ) -> CGRect {
        var frame = attributes.frame
        let scrollX = collectionView?.contentOffset.x ?? 0
        let naturalX = frame.origin.x
        var stickyX = max(scrollX + 8, naturalX)

        if headerIndex + 1 < dayHeaders.count {
            let nextNaturalX = CGFloat(dayHeaders[headerIndex + 1].itemIndex) * itemWidth
            stickyX = min(stickyX, nextNaturalX - headerWidth - 4)
        }

        frame.origin.x = stickyX
        return frame
    }
}
