public struct GeocodingResult: Decodable, Sendable, Equatable {
    public let name: String
    public let localNames: [String: String]?
    public let lat: Double
    public let lon: Double
    public let country: String
    public let state: String?

    public init(
        name: String,
        localNames: [String: String]?,
        lat: Double,
        lon: Double,
        country: String,
        state: String?
    ) {
        self.name = name
        self.localNames = localNames
        self.lat = lat
        self.lon = lon
        self.country = country
        self.state = state
    }

    enum CodingKeys: String, CodingKey {
        case name
        case localNames = "local_names"
        case lat
        case lon
        case country
        case state
    }
}
