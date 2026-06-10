import CoreGraphics
import Foundation
import UIKit

enum WeatherBackgroundConstants {
    enum Animation {
        static let gradientCrossfadeDuration: TimeInterval = 0.6
        static let celestialPulseDuration: TimeInterval = 4
        static let cloudFrontDurationScale: CGFloat = 0.88

        static let pulseOpacityMin: Float = 0.65
        static let pulseOpacityMax: Float = 1

        enum Key {
            static let pulse = "pulse"
            static let sway = "sway"
            static let fadeIn = "fadeIn"
            static let fadeOut = "fadeOut"
        }
    }

    enum Motion {
        static let referenceWindSpeed: Double = 10
        static let minCloudDriftDuration: TimeInterval = 12
        static let baseCloudDriftDuration: TimeInterval = 24
        static let cloudDriftDurationWindScale: TimeInterval = 10
        static let maxBackCloudDriftDistance: CGFloat = 160
        static let backCloudDriftBaseDistance: CGFloat = 48
        static let backCloudDriftWindScale: CGFloat = 12
        static let maxFrontCloudDriftDistance: CGFloat = 120
        static let frontCloudDriftBaseDistance: CGFloat = 36
        static let frontCloudDriftWindScale: CGFloat = 9
        static let cloudTextureWidthScale: CGFloat = 1.28
        static let maxCelestialSwayDistance: CGFloat = 18
        static let celestialSwayBaseDistance: CGFloat = 6
        static let celestialSwayWindScale: CGFloat = 1.2
        static let minCelestialSwayDuration: TimeInterval = 14
        static let baseCelestialSwayDuration: TimeInterval = 28
        static let celestialSwayDurationWindScale: TimeInterval = 12
    }

    enum Layout {
        static let wideCloudLayoutMinWidth: CGFloat = 700
        static let gradientStartPoint = CGPoint(x: 0.5, y: 0)
        static let gradientEndPoint = CGPoint(x: 0.5, y: 1)
        static let gradientLocationStart: NSNumber = 0
        static let gradientLocationEnd: NSNumber = 1
        static let particleEmitterVerticalOffset: CGFloat = -8
        static let particleEmitterLineHeight: CGFloat = 1
    }

    enum Cloud {
        static let minCoverageToShow = 15
        static let maxOpacity: Float = 0.55
        static let coverageScale: Float = 100
        static let skyVerticalCoverageRatio: CGFloat = 0.56
        static let frontBandVerticalOffset: CGFloat = 24
        static let maxLayerDensity: CGFloat = 0.9
        static let wideLayoutDensityScale: CGFloat = 0.78

        static let backLayerDensityScale: CGFloat = 0.72
        static let frontLayerDensityScale: CGFloat = 0.5
        static let backBandOpacityWide: CGFloat = 0.68
        static let backBandOpacityRegular: CGFloat = 0.72
        static let frontBandOpacityWide: CGFloat = 0.34
        static let frontBandOpacityRegular: CGFloat = 0.48

        static let backTextureVariant = 0
        static let frontTextureVariant = 5
        static let backLayerPhase: CGFloat = 0
        static let frontLayerPhase: CGFloat = 0.58

        enum Density {
            static let fogCloudyCap: CGFloat = 0.88
            static let fogCloudyFloor: CGFloat = 0.68
            static let precipCap: CGFloat = 0.82
            static let precipFloor: CGFloat = 0.58
            static let partlyCloudyCap: CGFloat = 0.55
            static let partlyCloudyFloor: CGFloat = 0.38
            static let defaultCap: CGFloat = 0.42
            static let defaultFloor: CGFloat = 0.28
        }
    }

    enum Celestial {
        static let bodyDiameter: CGFloat = 56
        static let horizontalAnchorRatio: CGFloat = 0.68
        static let verticalAnchorRatio: CGFloat = 0.08
        static let minimumVerticalAnchor: CGFloat = 56
        static let glowInset: CGFloat = 18

        enum Sun {
            static let bodyRed: CGFloat = 1
            static let bodyGreen: CGFloat = 0.92
            static let bodyBlue: CGFloat = 0.45
            static let glowRed: CGFloat = 1
            static let glowGreen: CGFloat = 0.85
            static let glowBlue: CGFloat = 0.35
            static let glowAlpha: CGFloat = 0.35
        }

        enum Moon {
            static let bodyWhite: CGFloat = 0.92
            static let glowWhite: CGFloat = 0.85
            static let glowAlpha: CGFloat = 0.22
        }
    }

    enum Storm {
        static let flashInterval: TimeInterval = 4.5
        static let flashTimerTolerance: TimeInterval = 1.2
        static let flashPeakDuration: TimeInterval = 0.08
        static let flashFadeDuration: TimeInterval = 0.25
        static let flashPeakAlpha: CGFloat = 0.18
    }

    enum Particle {
        static let baseRainBirthRate: Float = 180
        static let baseSnowBirthRate: Float = 90
        static let drizzleMultiplier: Float = 0.55
        static let stormMultiplier: Float = 1.35

        static let rainLifetime: Float = 1.2
        static let rainVelocity: CGFloat = 280
        static let rainVelocityRange: CGFloat = 60
        static let rainScale: CGFloat = 0.12
        static let rainScaleRange: CGFloat = 0.04
        static let rainAlphaRange: Float = 0.2

        static let snowLifetime: Float = 5
        static let snowVelocity: CGFloat = 45
        static let snowVelocityRange: CGFloat = 20
        static let snowSpin: CGFloat = 0.4
        static let snowSpinRange: CGFloat = 0.8
        static let snowScale: CGFloat = 0.2
        static let snowScaleRange: CGFloat = 0.08
        static let snowWindDriftMultiplier: CGFloat = 0.35
    }

    enum Wind {
        static let driftFactor: CGFloat = 12
        static let maxDrift: CGFloat = 80
    }

    enum Asset {
        enum RainDrop {
            static let width: CGFloat = 2
            static let height: CGFloat = 14
            static let fillWhite: CGFloat = 1
            static let fillAlpha: CGFloat = 0.75
        }

        enum Snowflake {
            static let diameter: CGFloat = 6
            static let fillWhite: CGFloat = 1
            static let fillAlpha: CGFloat = 0.9
        }

        enum CloudTexture {
            static let heightRatio: CGFloat = 0.36
            static let fillAlphaBase: CGFloat = 0.22
            static let fillAlphaDensityScale: CGFloat = 0.34
            static let hazeDensityThreshold: CGFloat = 0.62
            static let blurRadiusCap: CGFloat = 2.4
            static let blurRadiusBase: CGFloat = 1.4
            static let blurRadiusWidthScale: CGFloat = 900
            static let minColumnWidth: CGFloat = 200
            static let maxColumnWidth: CGFloat = 280
            static let columnWidthDivisor: CGFloat = 4.5
            static let rowHeight: CGFloat = 150
            static let minGridDimension = 2
            static let rowShiftRatio: CGFloat = 0.5
            static let variantSeedMultiplier = 113
            static let occupancyDensityScale: CGFloat = 0.95
            static let maxOccupancy: CGFloat = 0.92
            static let widthMinScale: CGFloat = 0.78
            static let widthRangeScale: CGFloat = 0.22
            static let cloudHeightRatio: CGFloat = 0.34
            static let jitterXSpanRatio: CGFloat = 0.14
            static let jitterYSpanRatio: CGFloat = 0.2
            static let wrapMarginRatio: CGFloat = 0.2
            static let centeringRatio: CGFloat = 0.5
            static let alphaScaleBase: CGFloat = 0.7
            static let alphaScaleRange: CGFloat = 0.3
            static let variantCount = 3
            static let baselineHeightRatio: CGFloat = 0.16
            static let hazeTopAlpha: CGFloat = 0.14
            static let hazeMidAlpha: CGFloat = 0.06
            static let hazeMidLocation: CGFloat = 0.45
            static let hazeEndLocation: CGFloat = 1
            static let hazeVerticalEndRatio: CGFloat = 0.72
            static let gaussianBlurFilterName = "CIGaussianBlur"
        }

        enum PrecipitationOverlay {
            static let drizzleStreakCount = 90
            static let rainStreakCount = 160
            static let stormStreakCount = 220
            static let drizzleAlpha: CGFloat = 0.35
            static let rainAlpha: CGFloat = 0.55
            static let stormAlpha: CGFloat = 0.65
            static let drizzleLineWidth: CGFloat = 1
            static let rainLineWidth: CGFloat = 1.2
            static let stormLineWidth: CGFloat = 1.4
            static let columnCount = 20
            static let snowflakeCount = 120
            static let snowColumnCount = 12
            static let snowRowCount = 9
            static let snowAlpha: CGFloat = 0.85
            static let snowRadiusBase: CGFloat = 1.2
            static let snowRadiusScale: CGFloat = 0.15
            static let streakLengthBase: CGFloat = 10
            static let drizzleDriftSpan: CGFloat = 6
            static let rainDriftSpan: CGFloat = 6
            static let stormDriftSpan: CGFloat = 6
            static let drizzleLengthSpan: CGFloat = 10
            static let rainLengthSpan: CGFloat = 10
            static let stormLengthSpan: CGFloat = 10
            static let drizzleXSpan: CGFloat = 14
            static let rainXSpan: CGFloat = 14
            static let stormXSpan: CGFloat = 14
            static let drizzleYSpan: CGFloat = 18
            static let rainYSpan: CGFloat = 18
            static let stormYSpan: CGFloat = 18
            static let snowXSpan: CGFloat = 20
            static let snowYSpan: CGFloat = 16
            static let snowRadiusSpan: CGFloat = 4
        }

        enum PseudoRandom {
            static let seedMultiplier = 1_103_515_245
            static let seedOffset = 12_345
            static let mask = 0x7fff
        }
    }
}
