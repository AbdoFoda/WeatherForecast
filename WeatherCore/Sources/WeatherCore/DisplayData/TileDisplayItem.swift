import Foundation

public struct TileDisplayItem: Sendable, Codable {
    public let id: String
    public let title: String
    public let value: String
    public let subtitle: String?
    public let tileSize: TileSize

    public enum TileSize: String, Sendable, Codable {
        case standard, wide, tall
    }

    public init(
        id: String,
        title: String,
        value: String,
        subtitle: String?,
        tileSize: TileSize
    ) {
        self.id = id
        self.title = title
        self.value = value
        self.subtitle = subtitle
        self.tileSize = tileSize
    }
}
