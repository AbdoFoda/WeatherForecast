import Foundation

public struct LocationCardSummary: Sendable, Equatable, Codable {
    public let temperature: String
    public let conditionText: String
    public let highLow: String
    public let localTime: String
    public let scene: WeatherScene

    public init(
        temperature: String,
        conditionText: String,
        highLow: String,
        localTime: String,
        scene: WeatherScene
    ) {
        self.temperature = temperature
        self.conditionText = conditionText
        self.highLow = highLow
        self.localTime = localTime
        self.scene = scene
    }
}
