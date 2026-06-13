import UIKit

extension WeatherBackgroundAssetFactory {
    private struct RainStreakStyle {
        let streakCount: Int
        let alpha: CGFloat
        let width: CGFloat
        let xSpan: CGFloat
        let ySpan: CGFloat
        let lengthSpan: CGFloat
        let driftSpan: CGFloat
    }

    static func drawRainOverlay(
        in context: CGContext,
        density: PrecipitationOverlayDensity,
        size: CGSize
    ) {
        guard let style = rainStreakStyle(for: density) else { return }

        let columnCount = WeatherBackgroundConstants.Asset.PrecipitationOverlay.columnCount
        let columnDivisor = CGFloat(columnCount - 1)
        let rowDivisor = CGFloat(style.streakCount / columnCount - 1)

        context.setStrokeColor(UIColor(white: 1, alpha: style.alpha).cgColor)
        context.setLineWidth(style.width)
        context.setLineCap(.round)

        for index in 0..<style.streakCount {
            let column = CGFloat(index % columnCount)
            let row = CGFloat(index / columnCount)
            let x = (column / columnDivisor) * size.width + pseudoOffset(index, span: style.xSpan)
            let y = (row / rowDivisor) * size.height + pseudoOffset(index + 3, span: style.ySpan)
            let length = pseudoOffset(index + 7, span: style.lengthSpan)
                + WeatherBackgroundConstants.Asset.PrecipitationOverlay.streakLengthBase
            let drift = pseudoOffset(index + 11, span: style.driftSpan)

            context.move(to: CGPoint(x: x, y: y))
            context.addLine(to: CGPoint(x: x + drift, y: y + length))
            context.strokePath()
        }
    }

    private static func rainStreakStyle(for density: PrecipitationOverlayDensity) -> RainStreakStyle? {
        let overlay = WeatherBackgroundConstants.Asset.PrecipitationOverlay.self
        switch density {
        case .drizzle:
            return RainStreakStyle(
                streakCount: overlay.drizzleStreakCount,
                alpha: overlay.drizzleAlpha,
                width: overlay.drizzleLineWidth,
                xSpan: overlay.drizzleXSpan,
                ySpan: overlay.drizzleYSpan,
                lengthSpan: overlay.drizzleLengthSpan,
                driftSpan: overlay.drizzleDriftSpan
            )
        case .rain:
            return RainStreakStyle(
                streakCount: overlay.rainStreakCount,
                alpha: overlay.rainAlpha,
                width: overlay.rainLineWidth,
                xSpan: overlay.rainXSpan,
                ySpan: overlay.rainYSpan,
                lengthSpan: overlay.rainLengthSpan,
                driftSpan: overlay.rainDriftSpan
            )
        case .storm:
            return RainStreakStyle(
                streakCount: overlay.stormStreakCount,
                alpha: overlay.stormAlpha,
                width: overlay.stormLineWidth,
                xSpan: overlay.stormXSpan,
                ySpan: overlay.stormYSpan,
                lengthSpan: overlay.stormLengthSpan,
                driftSpan: overlay.stormDriftSpan
            )
        case .snow:
            return nil
        }
    }

    static func drawSnowOverlay(in context: CGContext, size: CGSize) {
        let snowflakeCount = WeatherBackgroundConstants.Asset.PrecipitationOverlay.snowflakeCount
        let columnCount = WeatherBackgroundConstants.Asset.PrecipitationOverlay.snowColumnCount
        let rowCount = WeatherBackgroundConstants.Asset.PrecipitationOverlay.snowRowCount
        let columnDivisor = CGFloat(columnCount - 1)
        let rowDivisor = CGFloat(rowCount - 1)

        context.setFillColor(
            UIColor(white: 1, alpha: WeatherBackgroundConstants.Asset.PrecipitationOverlay.snowAlpha).cgColor
        )
        for index in 0..<snowflakeCount {
            let column = CGFloat(index % columnCount)
            let row = CGFloat(index / columnCount)
            let x = (column / columnDivisor) * size.width
                + pseudoOffset(index, span: WeatherBackgroundConstants.Asset.PrecipitationOverlay.snowXSpan)
            let y = (row / rowDivisor) * size.height
                + pseudoOffset(index + 5, span: WeatherBackgroundConstants.Asset.PrecipitationOverlay.snowYSpan)
            let radius = WeatherBackgroundConstants.Asset.PrecipitationOverlay.snowRadiusBase
                + pseudoOffset(index + 9, span: WeatherBackgroundConstants.Asset.PrecipitationOverlay.snowRadiusSpan)
                * WeatherBackgroundConstants.Asset.PrecipitationOverlay.snowRadiusScale
            context.fillEllipse(in: CGRect(x: x, y: y, width: radius * 2, height: radius * 2))
        }
    }
}
