public struct AirPollutionResponse: Decodable, Sendable {
    public let coord: Coordinate
    public let list: [AirPollutionItem]
}
