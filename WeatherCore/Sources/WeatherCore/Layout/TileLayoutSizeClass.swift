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
