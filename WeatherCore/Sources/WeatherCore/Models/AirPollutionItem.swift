import Foundation

public struct AirPollutionItem: Decodable, Sendable {
    public let main: AirQualityMain
    public let components: AirPollutionComponents
    public let dt: TimeInterval
}
