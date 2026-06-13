public struct Precipitation: Decodable, Sendable {
    public let oneHour: Double?
    public let threeHour: Double?

    enum CodingKeys: String, CodingKey {
        case oneHour = "1h"
        case threeHour = "3h"
    }
}
