import Foundation

public struct ForecastCity: Decodable, Sendable {
    public let id: Int
    public let name: String
    public let coord: Coordinate
    public let country: String?
    public let population: Int?
    public let timezone: Int
    public let sunrise: TimeInterval?
    public let sunset: TimeInterval?
}
