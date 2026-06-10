import UIKit

enum WeatherBackgroundAssetFactory {
    static func rainDropImage() -> CGImage {
        let size = CGSize(width: 2, height: 14)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            UIColor(white: 1, alpha: 0.75).setFill()
            context.fill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        }
        return image.cgImage!
    }

    static func snowflakeImage() -> CGImage {
        let size = CGSize(width: 6, height: 6)
        let renderer = UIGraphicsImageRenderer(size: size)
        let image = renderer.image { context in
            UIColor(white: 1, alpha: 0.9).setFill()
            context.cgContext.fillEllipse(in: CGRect(origin: .zero, size: size))
        }
        return image.cgImage!
    }

    static func cloudImage(width: CGFloat, height: CGFloat) -> UIImage {
        let size = CGSize(width: width, height: height)
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { context in
            let cg = context.cgContext
            cg.setFillColor(UIColor.white.withAlphaComponent(0.85).cgColor)
            let baseY = height * 0.55
            let puffs: [(CGFloat, CGFloat, CGFloat)] = [
                (width * 0.22, baseY, width * 0.18),
                (width * 0.42, baseY - height * 0.12, width * 0.22),
                (width * 0.62, baseY, width * 0.20),
                (width * 0.78, baseY + height * 0.04, width * 0.16),
            ]
            for puff in puffs {
                cg.fillEllipse(in: CGRect(
                    x: puff.0 - puff.2 / 2,
                    y: puff.1 - puff.2 / 2,
                    width: puff.2,
                    height: puff.2 * 0.72
                ))
            }
        }
    }
}
