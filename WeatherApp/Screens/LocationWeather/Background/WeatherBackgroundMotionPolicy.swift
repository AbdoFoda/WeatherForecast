import CoreGraphics
import Foundation

enum WeatherBackgroundMotionPolicy {
    struct CloudDrift {
        let backDistance: CGFloat
        let frontDistance: CGFloat
        let duration: TimeInterval
    }

    static func cloudDrift(windSpeed: Double) -> CloudDrift {
        let speed = max(0, windSpeed)
        let intensity = min(1, speed / WeatherBackgroundConstants.Motion.referenceWindSpeed)
        let duration = max(
            WeatherBackgroundConstants.Motion.minCloudDriftDuration,
            WeatherBackgroundConstants.Motion.baseCloudDriftDuration
                - intensity * WeatherBackgroundConstants.Motion.cloudDriftDurationWindScale
        )
        let backDistance = min(
            WeatherBackgroundConstants.Motion.maxBackCloudDriftDistance,
            WeatherBackgroundConstants.Motion.backCloudDriftBaseDistance
                + CGFloat(speed) * WeatherBackgroundConstants.Motion.backCloudDriftWindScale
        )
        let frontDistance = min(
            WeatherBackgroundConstants.Motion.maxFrontCloudDriftDistance,
            WeatherBackgroundConstants.Motion.frontCloudDriftBaseDistance
                + CGFloat(speed) * WeatherBackgroundConstants.Motion.frontCloudDriftWindScale
        )

        return CloudDrift(
            backDistance: backDistance,
            frontDistance: -frontDistance,
            duration: duration
        )
    }

    static func cloudTextureWidth(for containerWidth: CGFloat) -> CGFloat {
        containerWidth * WeatherBackgroundConstants.Motion.cloudTextureWidthScale
    }

    static func celestialSwayDistance(windSpeed: Double) -> CGFloat {
        min(
            WeatherBackgroundConstants.Motion.maxCelestialSwayDistance,
            WeatherBackgroundConstants.Motion.celestialSwayBaseDistance
                + CGFloat(max(0, windSpeed)) * WeatherBackgroundConstants.Motion.celestialSwayWindScale
        )
    }

    static func celestialSwayDuration(windSpeed: Double) -> TimeInterval {
        let intensity = min(1, max(0, windSpeed) / WeatherBackgroundConstants.Motion.referenceWindSpeed)
        return max(
            WeatherBackgroundConstants.Motion.minCelestialSwayDuration,
            WeatherBackgroundConstants.Motion.baseCelestialSwayDuration
                - intensity * WeatherBackgroundConstants.Motion.celestialSwayDurationWindScale
        )
    }
}
