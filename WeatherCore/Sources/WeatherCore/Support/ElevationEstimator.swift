import Foundation

public enum ElevationEstimator {
    // International barometric formula: h = scale * (1 - (p/p0)^exponent)
    private enum Barometric {
        static let scaleMeters = 44_330.0
        static let pressureExponent = 1.0 / 5.255
    }

    public static func metersAboveSeaLevel(from main: MainWeather) -> Double? {
        metersAboveSeaLevel(
            seaLevelHPa: main.seaLevel,
            groundLevelHPa: main.grndLevel,
            fallbackSeaLevelHPa: main.pressure
        )
    }

    public static func metersAboveSeaLevel(
        seaLevelHPa: Int?,
        groundLevelHPa: Int?,
        fallbackSeaLevelHPa: Int?
    ) -> Double? {
        guard let ground = groundLevelHPa, ground > 0 else { return nil }
        let sea = seaLevelHPa ?? fallbackSeaLevelHPa
        guard let sea, sea > 0, ground <= sea else { return nil }

        let ratio = Double(ground) / Double(sea)
        guard ratio > 0 else { return nil }
        return Barometric.scaleMeters * (1.0 - pow(ratio, Barometric.pressureExponent))
    }
}
