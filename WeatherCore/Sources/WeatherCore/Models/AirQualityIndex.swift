public enum AirQualityIndex: Int, Sendable {
    case good = 1
    case fair = 2
    case moderate = 3
    case poor = 4
    case veryPoor = 5

    public static func label(for rawAPIValue: Int) -> String {
        guard let index = AirQualityIndex(rawValue: rawAPIValue) else {
            return L10n.AirQuality.unknown
        }
        return index.localizedLabel
    }

    public var localizedLabel: String {
        switch self {
        case .good:
            return L10n.AirQuality.good
        case .fair:
            return L10n.AirQuality.fair
        case .moderate:
            return L10n.AirQuality.moderate
        case .poor:
            return L10n.AirQuality.poor
        case .veryPoor:
            return L10n.AirQuality.veryPoor
        }
    }
}
