public struct WeatherCondition: Decodable, Sendable {
    public let id: Int
    public let main: String
    public let description: String
    public let icon: String
}
