import UIKit

enum WeatherBackgroundAssetFactory {
    static func rainDropImage() -> CGImage {
        let size = CGSize(
            width: WeatherBackgroundConstants.Asset.RainDrop.width,
            height: WeatherBackgroundConstants.Asset.RainDrop.height
        )
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            UIColor(
                white: WeatherBackgroundConstants.Asset.RainDrop.fillWhite,
                alpha: WeatherBackgroundConstants.Asset.RainDrop.fillAlpha
            ).setFill()
            context.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        }
        guard let cgImage = image.cgImage else {
            preconditionFailure("UIGraphicsImageRenderer failed to produce a CGImage")
        }
        return cgImage
    }

    static func snowflakeImage() -> CGImage {
        let diameter = WeatherBackgroundConstants.Asset.Snowflake.diameter
        let size = CGSize(width: diameter, height: diameter)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            UIColor(
                white: WeatherBackgroundConstants.Asset.Snowflake.fillWhite,
                alpha: WeatherBackgroundConstants.Asset.Snowflake.fillAlpha
            ).setFill()
            context.cgContext.fillEllipse(in: CGRect(origin: .zero, size: size))
        }
        guard let cgImage = image.cgImage else {
            preconditionFailure("UIGraphicsImageRenderer failed to produce a CGImage")
        }
        return cgImage
    }

    static func cloudSkyTexture(
        size: CGSize,
        density: CGFloat,
        variant: Int,
        layerPhase: CGFloat = 0
    ) -> UIImage {
        guard size.width > 0, size.height > 0 else {
            return UIImage()
        }

        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            let cg = context.cgContext
            let placements = cloudPlacements(
                in: size,
                density: density,
                variant: variant,
                layerPhase: layerPhase
            )
            let fillAlpha = WeatherBackgroundConstants.Asset.CloudTexture.fillAlphaBase
                + density * WeatherBackgroundConstants.Asset.CloudTexture.fillAlphaDensityScale

            for placement in placements {
                let rect = CGRect(
                    x: placement.origin.x,
                    y: placement.origin.y,
                    width: placement.width,
                    height: placement.width * WeatherBackgroundConstants.Asset.CloudTexture.heightRatio
                )
                drawCloudUnit(
                    in: cg,
                    rect: rect,
                    variant: placement.variant,
                    alpha: fillAlpha * placement.alphaScale
                )
            }

            if density >= WeatherBackgroundConstants.Asset.CloudTexture.hazeDensityThreshold {
                drawOvercastHaze(in: cg, size: size, strength: density)
            }
        }

        let blurRadius = min(
            WeatherBackgroundConstants.Asset.CloudTexture.blurRadiusCap,
            WeatherBackgroundConstants.Asset.CloudTexture.blurRadiusBase
                + size.width / WeatherBackgroundConstants.Asset.CloudTexture.blurRadiusWidthScale
        )
        return soften(image, radius: blurRadius)
    }

    enum PrecipitationOverlayDensity {
        case drizzle
        case rain
        case storm
        case snow
    }

    static func precipitationOverlayImage(
        density: PrecipitationOverlayDensity,
        size: CGSize
    ) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let cg = context.cgContext
            switch density {
            case .drizzle, .rain, .storm:
                drawRainOverlay(in: cg, density: density, size: size)
            case .snow:
                drawSnowOverlay(in: cg, size: size)
            }
        }
    }

    private struct CloudPlacement {
        let origin: CGPoint
        let width: CGFloat
        let variant: Int
        let alphaScale: CGFloat
    }

    private static func drawRainOverlay(
        in context: CGContext,
        density: PrecipitationOverlayDensity,
        size: CGSize
    ) {
        let streakCount: Int
        let alpha: CGFloat
        let width: CGFloat
        let xSpan: CGFloat
        let ySpan: CGFloat
        let lengthSpan: CGFloat
        let driftSpan: CGFloat

        switch density {
        case .drizzle:
            streakCount = WeatherBackgroundConstants.Asset.PrecipitationOverlay.drizzleStreakCount
            alpha = WeatherBackgroundConstants.Asset.PrecipitationOverlay.drizzleAlpha
            width = WeatherBackgroundConstants.Asset.PrecipitationOverlay.drizzleLineWidth
            xSpan = WeatherBackgroundConstants.Asset.PrecipitationOverlay.drizzleXSpan
            ySpan = WeatherBackgroundConstants.Asset.PrecipitationOverlay.drizzleYSpan
            lengthSpan = WeatherBackgroundConstants.Asset.PrecipitationOverlay.drizzleLengthSpan
            driftSpan = WeatherBackgroundConstants.Asset.PrecipitationOverlay.drizzleDriftSpan
        case .rain:
            streakCount = WeatherBackgroundConstants.Asset.PrecipitationOverlay.rainStreakCount
            alpha = WeatherBackgroundConstants.Asset.PrecipitationOverlay.rainAlpha
            width = WeatherBackgroundConstants.Asset.PrecipitationOverlay.rainLineWidth
            xSpan = WeatherBackgroundConstants.Asset.PrecipitationOverlay.rainXSpan
            ySpan = WeatherBackgroundConstants.Asset.PrecipitationOverlay.rainYSpan
            lengthSpan = WeatherBackgroundConstants.Asset.PrecipitationOverlay.rainLengthSpan
            driftSpan = WeatherBackgroundConstants.Asset.PrecipitationOverlay.rainDriftSpan
        case .storm:
            streakCount = WeatherBackgroundConstants.Asset.PrecipitationOverlay.stormStreakCount
            alpha = WeatherBackgroundConstants.Asset.PrecipitationOverlay.stormAlpha
            width = WeatherBackgroundConstants.Asset.PrecipitationOverlay.stormLineWidth
            xSpan = WeatherBackgroundConstants.Asset.PrecipitationOverlay.stormXSpan
            ySpan = WeatherBackgroundConstants.Asset.PrecipitationOverlay.stormYSpan
            lengthSpan = WeatherBackgroundConstants.Asset.PrecipitationOverlay.stormLengthSpan
            driftSpan = WeatherBackgroundConstants.Asset.PrecipitationOverlay.stormDriftSpan
        case .snow:
            return
        }

        let columnCount = WeatherBackgroundConstants.Asset.PrecipitationOverlay.columnCount
        let columnDivisor = CGFloat(columnCount - 1)
        let rowDivisor = CGFloat(streakCount / columnCount - 1)

        context.setStrokeColor(UIColor(white: 1, alpha: alpha).cgColor)
        context.setLineWidth(width)
        context.setLineCap(.round)

        for index in 0..<streakCount {
            let column = CGFloat(index % columnCount)
            let row = CGFloat(index / columnCount)
            let x = (column / columnDivisor) * size.width + pseudoOffset(index, span: xSpan)
            let y = (row / rowDivisor) * size.height + pseudoOffset(index + 3, span: ySpan)
            let length = pseudoOffset(index + 7, span: lengthSpan)
                + WeatherBackgroundConstants.Asset.PrecipitationOverlay.streakLengthBase
            let drift = pseudoOffset(index + 11, span: driftSpan)

            context.move(to: CGPoint(x: x, y: y))
            context.addLine(to: CGPoint(x: x + drift, y: y + length))
            context.strokePath()
        }
    }

    private static func drawSnowOverlay(in context: CGContext, size: CGSize) {
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

    private static func cloudPlacements(
        in size: CGSize,
        density: CGFloat,
        variant: Int,
        layerPhase: CGFloat
    ) -> [CloudPlacement] {
        let skyHeight = size.height * WeatherBackgroundConstants.Cloud.skyVerticalCoverageRatio
        let columnWidth = max(
            WeatherBackgroundConstants.Asset.CloudTexture.minColumnWidth,
            min(
                WeatherBackgroundConstants.Asset.CloudTexture.maxColumnWidth,
                size.width / WeatherBackgroundConstants.Asset.CloudTexture.columnWidthDivisor
            )
        )
        let rowHeight = WeatherBackgroundConstants.Asset.CloudTexture.rowHeight
        let columns = max(
            WeatherBackgroundConstants.Asset.CloudTexture.minGridDimension,
            Int(ceil(size.width / columnWidth))
        )
        let rows = max(
            WeatherBackgroundConstants.Asset.CloudTexture.minGridDimension,
            Int(ceil(skyHeight / rowHeight))
        )
        let cellWidth = size.width / CGFloat(columns)
        let cellHeight = skyHeight / CGFloat(rows)
        let horizontalShift = layerPhase * cellWidth
        var placements: [CloudPlacement] = []

        for row in 0..<rows {
            let rowShift = row.isMultiple(of: 2)
                ? CGFloat.zero
                : cellWidth * WeatherBackgroundConstants.Asset.CloudTexture.rowShiftRatio
            for column in 0..<columns {
                let seed = row &* columns &+ column &+ variant
                    &* WeatherBackgroundConstants.Asset.CloudTexture.variantSeedMultiplier
                let occupancyThreshold = 1 - min(
                    WeatherBackgroundConstants.Asset.CloudTexture.maxOccupancy,
                    density * WeatherBackgroundConstants.Asset.CloudTexture.occupancyDensityScale
                )
                if pseudoUnit(seed &+ 7) < occupancyThreshold {
                    continue
                }

                let width = cellWidth * (
                    WeatherBackgroundConstants.Asset.CloudTexture.widthMinScale
                        + pseudoUnit(seed) * WeatherBackgroundConstants.Asset.CloudTexture.widthRangeScale
                )
                let jitterX = pseudoOffset(
                    seed &+ 1,
                    span: cellWidth * WeatherBackgroundConstants.Asset.CloudTexture.jitterXSpanRatio
                )
                let jitterY = pseudoOffset(
                    seed &+ 2,
                    span: cellHeight * WeatherBackgroundConstants.Asset.CloudTexture.jitterYSpanRatio
                )
                var x = CGFloat(column) * cellWidth
                    + (cellWidth - width) * WeatherBackgroundConstants.Asset.CloudTexture.centeringRatio
                    + rowShift + horizontalShift + jitterX
                let wrapMargin = cellWidth * WeatherBackgroundConstants.Asset.CloudTexture.wrapMarginRatio
                if x + width > size.width + wrapMargin {
                    x -= cellWidth
                }
                if x < -wrapMargin {
                    x += cellWidth
                }
                let y = CGFloat(row) * cellHeight + jitterY
                let alphaScale = WeatherBackgroundConstants.Asset.CloudTexture.alphaScaleBase
                    + pseudoUnit(seed &+ 3) * WeatherBackgroundConstants.Asset.CloudTexture.alphaScaleRange

                placements.append(CloudPlacement(
                    origin: CGPoint(x: x, y: y),
                    width: width,
                    variant: (seed &+ 4) % WeatherBackgroundConstants.Asset.CloudTexture.variantCount,
                    alphaScale: alphaScale
                ))
            }
        }

        return placements
    }

    private static func drawOvercastHaze(
        in context: CGContext,
        size: CGSize,
        strength: CGFloat
    ) {
        let colors = [
            UIColor.white.withAlphaComponent(
                WeatherBackgroundConstants.Asset.CloudTexture.hazeTopAlpha * strength
            ).cgColor,
            UIColor.white.withAlphaComponent(
                WeatherBackgroundConstants.Asset.CloudTexture.hazeMidAlpha * strength
            ).cgColor,
            UIColor.clear.cgColor,
        ] as CFArray
        let locations: [CGFloat] = [
            0,
            WeatherBackgroundConstants.Asset.CloudTexture.hazeMidLocation,
            WeatherBackgroundConstants.Asset.CloudTexture.hazeEndLocation,
        ]
        guard let gradient = CGGradient(
            colorsSpace: CGColorSpaceCreateDeviceRGB(),
            colors: colors,
            locations: locations
        ) else { return }
        context.saveGState()
        context.drawLinearGradient(
            gradient,
            start: CGPoint(x: size.width * 0.5, y: 0),
            end: CGPoint(
                x: size.width * 0.5,
                y: size.height * WeatherBackgroundConstants.Asset.CloudTexture.hazeVerticalEndRatio
            ),
            options: []
        )
        context.restoreGState()
    }

    private static func drawCloudUnit(
        in context: CGContext,
        rect: CGRect,
        variant: Int,
        alpha: CGFloat
    ) {
        let path = cloudUnitPath(in: rect, variant: variant)
        context.saveGState()
        context.setFillColor(UIColor.white.withAlphaComponent(alpha).cgColor)
        context.addPath(path.cgPath)
        context.fillPath()
        context.restoreGState()
    }

    private static func cloudUnitPath(in rect: CGRect, variant: Int) -> UIBezierPath {
        let path = UIBezierPath()
        let baseline = rect.maxY - rect.height * WeatherBackgroundConstants.Asset.CloudTexture.baselineHeightRatio
        let templates: [[(CGFloat, CGFloat)]] = [
            [(0.18, 0.58), (0.50, 0.78), (0.82, 0.52)],
            [(0.22, 0.62), (0.54, 0.68), (0.86, 0.56)],
            [(0.14, 0.50), (0.46, 0.74), (0.76, 0.48)],
        ]
        let bumps = templates[variant % templates.count]

        path.move(to: CGPoint(x: rect.minX, y: baseline))
        for (xFactor, radiusFactor) in bumps {
            let radius = rect.height * radiusFactor
            path.addArc(
                withCenter: CGPoint(x: rect.minX + rect.width * xFactor, y: baseline),
                radius: radius,
                startAngle: .pi,
                endAngle: 0,
                clockwise: true
            )
        }
        path.addLine(to: CGPoint(x: rect.maxX, y: baseline))
        path.close()
        return path
    }

    private static func soften(_ image: UIImage, radius: CGFloat) -> UIImage {
        guard let ciImage = CIImage(image: image) else { return image }
        guard let filter = CIFilter(name: WeatherBackgroundConstants.Asset.CloudTexture.gaussianBlurFilterName) else {
            return image
        }

        filter.setValue(ciImage, forKey: kCIInputImageKey)
        filter.setValue(radius, forKey: kCIInputRadiusKey)
        guard let output = filter.outputImage else { return image }

        let context = CIContext(options: nil)
        let cropped = output.cropped(to: ciImage.extent)
        guard let cgImage = context.createCGImage(cropped, from: ciImage.extent) else {
            return image
        }
        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }

    private static func pseudoOffset(_ seed: Int, span: CGFloat) -> CGFloat {
        CGFloat(pseudoUnit(seed)) * span
    }

    private static func pseudoUnit(_ seed: Int) -> CGFloat {
        let value = (
            seed &* WeatherBackgroundConstants.Asset.PseudoRandom.seedMultiplier
                &+ WeatherBackgroundConstants.Asset.PseudoRandom.seedOffset
        ) & WeatherBackgroundConstants.Asset.PseudoRandom.mask
        return CGFloat(value) / CGFloat(WeatherBackgroundConstants.Asset.PseudoRandom.mask)
    }
}
