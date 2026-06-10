import CoreGraphics
import WeatherCore

enum WeatherBackgroundCloudPolicy {
    enum Layer {
        case back
        case front
    }

    static func isWideLayout(width: CGFloat) -> Bool {
        width > WeatherBackgroundConstants.Layout.wideCloudLayoutMinWidth
    }

    static func density(scene: WeatherScene, cloudCoveragePercent: Int) -> CGFloat {
        let coverage = CGFloat(cloudCoveragePercent) / CGFloat(WeatherBackgroundConstants.Cloud.coverageScale)
        switch scene {
        case .fog, .cloudy:
            return min(
                WeatherBackgroundConstants.Cloud.Density.fogCloudyCap,
                max(coverage, WeatherBackgroundConstants.Cloud.Density.fogCloudyFloor)
            )
        case .rain, .drizzle, .thunderstorm, .snow:
            return min(
                WeatherBackgroundConstants.Cloud.Density.precipCap,
                max(coverage, WeatherBackgroundConstants.Cloud.Density.precipFloor)
            )
        case .partlyCloudyDay, .partlyCloudyNight:
            return min(
                WeatherBackgroundConstants.Cloud.Density.partlyCloudyCap,
                max(coverage, WeatherBackgroundConstants.Cloud.Density.partlyCloudyFloor)
            )
        default:
            return min(
                WeatherBackgroundConstants.Cloud.Density.defaultCap,
                max(coverage, WeatherBackgroundConstants.Cloud.Density.defaultFloor)
            )
        }
    }

    static func adjustedLayerDensity(_ density: CGFloat, wide: Bool, layer: Layer) -> CGFloat {
        let layerScale = layer == .back
            ? WeatherBackgroundConstants.Cloud.backLayerDensityScale
            : WeatherBackgroundConstants.Cloud.frontLayerDensityScale
        let wideScale = wide ? WeatherBackgroundConstants.Cloud.wideLayoutDensityScale : 1
        return min(
            WeatherBackgroundConstants.Cloud.maxLayerDensity,
            density * layerScale * wideScale
        )
    }

    static func bandOpacityMultiplier(wide: Bool, layer: Layer) -> CGFloat {
        switch (wide, layer) {
        case (true, .back):
            return WeatherBackgroundConstants.Cloud.backBandOpacityWide
        case (false, .back):
            return WeatherBackgroundConstants.Cloud.backBandOpacityRegular
        case (true, .front):
            return WeatherBackgroundConstants.Cloud.frontBandOpacityWide
        case (false, .front):
            return WeatherBackgroundConstants.Cloud.frontBandOpacityRegular
        }
    }
}
