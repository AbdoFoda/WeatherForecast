import Foundation

public struct LocationDetails: Sendable, Equatable {
    public let postalCode: String?
    public let altitudeMeters: Double?

    public init(postalCode: String? = nil, altitudeMeters: Double? = nil) {
        self.postalCode = postalCode
        self.altitudeMeters = altitudeMeters
    }

    public var isEmpty: Bool {
        postalCode == nil && altitudeMeters == nil
    }
}
