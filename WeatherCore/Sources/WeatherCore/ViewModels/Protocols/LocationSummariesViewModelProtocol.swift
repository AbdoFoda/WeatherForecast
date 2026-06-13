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

@MainActor
public protocol LocationSummariesViewModelProtocol: AnyObject, Sendable {
    var onChange: (([String: LocationCardSummary]) -> Void)? { get set }
    var summaries: [String: LocationCardSummary] { get }

    func refresh(_ requests: [LocationSummaryRequest])
    func reload(_ requests: [LocationSummaryRequest])
}
