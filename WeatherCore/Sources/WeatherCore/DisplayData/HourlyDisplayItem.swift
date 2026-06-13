import CoreGraphics
import Foundation

public struct HourlyDisplayItem: Sendable, Codable {
    public let time: String
    public let temperature: String
    public let iconURL: URL?
    public let temperatureDotY: CGFloat
    public let isCurrentHour: Bool
    public let dayLabel: String?
    public let precipitationChance: String?

    public init(
        time: String,
        temperature: String,
        iconURL: URL?,
        temperatureDotY: CGFloat,
        isCurrentHour: Bool,
        dayLabel: String?,
        precipitationChance: String?
    ) {
        self.time = time
        self.temperature = temperature
        self.iconURL = iconURL
        self.temperatureDotY = temperatureDotY
        self.isCurrentHour = isCurrentHour
        self.dayLabel = dayLabel
        self.precipitationChance = precipitationChance
    }
}
