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

    static func pseudoOffset(_ seed: Int, span: CGFloat) -> CGFloat {
        CGFloat(pseudoUnit(seed)) * span
    }

    static func pseudoUnit(_ seed: Int) -> CGFloat {
        let value = (
            seed &* WeatherBackgroundConstants.Asset.PseudoRandom.seedMultiplier
                &+ WeatherBackgroundConstants.Asset.PseudoRandom.seedOffset
        ) & WeatherBackgroundConstants.Asset.PseudoRandom.mask
        return CGFloat(value) / CGFloat(WeatherBackgroundConstants.Asset.PseudoRandom.mask)
    }
}
