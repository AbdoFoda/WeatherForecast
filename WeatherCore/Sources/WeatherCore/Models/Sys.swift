import Foundation

public struct Sys: Decodable, Sendable {
    public let type: Int?
    public let id: Int?
    public let country: String?
    public let sunrise: TimeInterval?
    public let sunset: TimeInterval?
}
