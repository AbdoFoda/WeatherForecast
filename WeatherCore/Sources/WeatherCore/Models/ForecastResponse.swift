public struct ForecastResponse: Decodable, Sendable {
    public let cod: String
    public let message: Int?
    public let cnt: Int
    public let list: [HourlyForecastItem]
    public let city: ForecastCity
}
