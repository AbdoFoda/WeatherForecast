import CoreGraphics
import Foundation

public enum TileOrderApplier {
    public static func apply(order: [TileKind], to tiles: [TileDisplayItem]) -> [TileDisplayItem] {
        let tilesByKind = tiles.reduce(into: [TileKind: TileDisplayItem]()) { partialResult, tile in
            guard let kind = TileKind(rawValue: tile.id), partialResult[kind] == nil else { return }
            partialResult[kind] = tile
        }

        var result: [TileDisplayItem] = []
        var seen = Set<TileKind>()

        for kind in order {
            guard let tile = tilesByKind[kind] else { continue }
            result.append(tile)
            seen.insert(kind)
        }

        for tile in tiles {
            guard let kind = TileKind(rawValue: tile.id), !seen.contains(kind) else { continue }
            result.append(tile)
        }

        return result
    }

    public static func reorder(
        order: [TileKind],
        moving kind: TileKind,
        toVisibleIndex destination: Int,
        visibleKinds: [TileKind]
    ) -> [TileKind] {
        var visibleOrdered = order.filter { visibleKinds.contains($0) }
        guard let source = visibleOrdered.firstIndex(of: kind) else { return order }

        visibleOrdered.remove(at: source)
        let clampedDestination = max(0, min(destination, visibleOrdered.count))
        visibleOrdered.insert(kind, at: clampedDestination)

        var visibleQueue = visibleOrdered
        return order.map { existingKind in
            if visibleKinds.contains(existingKind) {
                return visibleQueue.removeFirst()
            }
            return existingKind
        }
    }

    public static func visibleKinds(
        from tiles: [TileDisplayItem],
        containerWidth: CGFloat
    ) -> [TileKind] {
        TileVisibilityPolicy.visibleTiles(from: tiles, containerWidth: containerWidth)
            .compactMap { TileKind(rawValue: $0.id) }
    }

    public static func order(from tiles: [TileDisplayItem]) -> [TileKind] {
        tiles.compactMap { TileKind(rawValue: $0.id) }
    }
}
