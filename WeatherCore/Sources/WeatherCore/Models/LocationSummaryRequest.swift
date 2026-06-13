import Foundation

public struct LocationSummaryRequest: Sendable, Equatable {
    public let id: String
    public let lat: Double
    public let lon: Double

    public init(id: String, lat: Double, lon: Double) {
        self.id = id
        self.lat = lat
        self.lon = lon
    }
}
