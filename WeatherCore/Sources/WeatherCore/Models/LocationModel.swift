public struct LocationModel: Codable, Sendable, Equatable {
    public let id: String
    public let name: String
    public let lat: Double
    public let lon: Double
    public let country: String?
    public let postalCode: String?
    public let altitude: Double?

    public init(
        id: String,
        name: String,
        lat: Double,
        lon: Double,
        country: String?,
        postalCode: String? = nil,
        altitude: Double? = nil
    ) {
        self.id = id
        self.name = name
        self.lat = lat
        self.lon = lon
        self.country = country
        self.postalCode = postalCode
        self.altitude = altitude
    }
}
