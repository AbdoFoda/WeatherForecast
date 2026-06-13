import UIKit

extension WeatherBackgroundAssetFactory {
    struct CloudPlacement {
        let origin: CGPoint
        let width: CGFloat
        let variant: Int
        let alphaScale: CGFloat
    }

    private struct CloudGrid {
        let columns: Int
        let rows: Int
        let cellWidth: CGFloat
        let cellHeight: CGFloat
        let horizontalShift: CGFloat
        let containerWidth: CGFloat
        let variant: Int
        let density: CGFloat
    }

    static func cloudPlacements(
        in size: CGSize,
        density: CGFloat,
        variant: Int,
        layerPhase: CGFloat
    ) -> [CloudPlacement] {
        let grid = cloudGridGeometry(in: size, layerPhase: layerPhase, variant: variant, density: density)
        var placements: [CloudPlacement] = []

        for row in 0..<grid.rows {
            for column in 0..<grid.columns {
                if let placement = cloudPlacement(row: row, column: column, grid: grid) {
                    placements.append(placement)
                }
            }
        }

        return placements
    }

    private static func cloudGridGeometry(
        in size: CGSize,
        layerPhase: CGFloat,
        variant: Int,
        density: CGFloat
    ) -> CloudGrid {
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
        return CloudGrid(
            columns: columns,
            rows: rows,
            cellWidth: cellWidth,
            cellHeight: cellHeight,
            horizontalShift: layerPhase * cellWidth,
            containerWidth: size.width,
            variant: variant,
            density: density
        )
    }

    private static func cloudPlacement(row: Int, column: Int, grid: CloudGrid) -> CloudPlacement? {
        let rowShift = row.isMultiple(of: 2)
            ? CGFloat.zero
            : grid.cellWidth * WeatherBackgroundConstants.Asset.CloudTexture.rowShiftRatio
        let seed = row &* grid.columns &+ column &+ grid.variant
            &* WeatherBackgroundConstants.Asset.CloudTexture.variantSeedMultiplier
        let occupancyThreshold = 1 - min(
            WeatherBackgroundConstants.Asset.CloudTexture.maxOccupancy,
            grid.density * WeatherBackgroundConstants.Asset.CloudTexture.occupancyDensityScale
        )
        if pseudoUnit(seed &+ 7) < occupancyThreshold {
            return nil
        }

        let width = grid.cellWidth * (
            WeatherBackgroundConstants.Asset.CloudTexture.widthMinScale
                + pseudoUnit(seed) * WeatherBackgroundConstants.Asset.CloudTexture.widthRangeScale
        )
        let jitterX = pseudoOffset(
            seed &+ 1,
            span: grid.cellWidth * WeatherBackgroundConstants.Asset.CloudTexture.jitterXSpanRatio
        )
        let jitterY = pseudoOffset(
            seed &+ 2,
            span: grid.cellHeight * WeatherBackgroundConstants.Asset.CloudTexture.jitterYSpanRatio
        )
        var x = CGFloat(column) * grid.cellWidth
            + (grid.cellWidth - width) * WeatherBackgroundConstants.Asset.CloudTexture.centeringRatio
            + rowShift + grid.horizontalShift + jitterX
        let wrapMargin = grid.cellWidth * WeatherBackgroundConstants.Asset.CloudTexture.wrapMarginRatio
        if x + width > grid.containerWidth + wrapMargin {
            x -= grid.cellWidth
        }
        if x < -wrapMargin {
            x += grid.cellWidth
        }
        let y = CGFloat(row) * grid.cellHeight + jitterY
        let alphaScale = WeatherBackgroundConstants.Asset.CloudTexture.alphaScaleBase
            + pseudoUnit(seed &+ 3) * WeatherBackgroundConstants.Asset.CloudTexture.alphaScaleRange

        return CloudPlacement(
            origin: CGPoint(x: x, y: y),
            width: width,
            variant: (seed &+ 4) % WeatherBackgroundConstants.Asset.CloudTexture.variantCount,
            alphaScale: alphaScale
        )
    }

    static func drawOvercastHaze(
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
            UIColor.clear.cgColor
        ] as CFArray
        let locations: [CGFloat] = [
            0,
            WeatherBackgroundConstants.Asset.CloudTexture.hazeMidLocation,
            WeatherBackgroundConstants.Asset.CloudTexture.hazeEndLocation
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

    static func drawCloudUnit(
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
            [(0.14, 0.50), (0.46, 0.74), (0.76, 0.48)]
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

    static func soften(_ image: UIImage, radius: CGFloat) -> UIImage {
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
}
