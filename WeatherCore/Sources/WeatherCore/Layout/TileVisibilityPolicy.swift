import CoreGraphics
import Foundation

public enum TileLayoutSizeClass: Sendable, Equatable {
    case compact
    case regular
    case large

    public static func from(containerWidth: CGFloat) -> TileLayoutSizeClass {
        if containerWidth >= WeatherConstants.TileLayout.largeTabletMinWidth {
            return .large
        }
        if containerWidth >= WeatherConstants.TileLayout.tabletMinWidth {
            return .regular
        }
        return .compact
    }
}

public enum TileVisibilityPolicy {
    public static func visibleTiles(
        from tiles: [TileDisplayItem],
        containerWidth: CGFloat
    ) -> [TileDisplayItem] {
        let allowedKinds = allowedKinds(for: TileLayoutSizeClass.from(containerWidth: containerWidth))
        return tiles.filter { tile in
            guard let kind = TileKind(rawValue: tile.id) else { return true }
            return allowedKinds.contains(kind)
        }
    }

    private static func allowedKinds(for sizeClass: TileLayoutSizeClass) -> Set<TileKind> {
        switch sizeClass {
        case .compact:
            return [
                .feelsLike,
                .humidity,
                .wind,
                .pressure,
                .sun,
                .air,
            ]
        case .regular:
            return [
                .feelsLike,
                .humidity,
                .wind,
                .pressure,
                .sun,
                .air,
                .visibility,
                .clouds,
            ]
        case .large:
            return Set(TileKind.allCases)
        }
    }
}
