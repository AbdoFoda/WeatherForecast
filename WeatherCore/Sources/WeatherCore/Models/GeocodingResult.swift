public struct GeocodingResult: Decodable, Sendable {
    public let name: String
    public let localNames: [String: String]?
    public let lat: Double
    public let lon: Double
    public let country: String
    public let state: String?
    
    enum CodingKeys: String, CodingKey {
        case name
        case localNames = "local_names"
        case lat
        case lon
        case country
        case state
    }
}
