import UIKit
import WeatherCore

enum TemperatureGraphRenderer {
    private static let graphInset: CGFloat = 10

    static func curvePath(
        cellWidth: CGFloat,
        graphTop: CGFloat,
        graphHeight: CGFloat,
        prevNormalizedY: CGFloat,
        currentNormalizedY: CGFloat,
        nextNormalizedY: CGFloat
    ) -> UIBezierPath {
        let yInGraph: (CGFloat) -> CGFloat = {
            TemperatureGraphGeometry.dotY(normalized: $0, graphHeight: graphHeight, inset: graphInset)
        }

        let centerX = cellWidth / 2
        let p0 = CGPoint(x: -cellWidth / 2, y: graphTop + yInGraph(prevNormalizedY))
        let p1 = CGPoint(x: centerX, y: graphTop + yInGraph(currentNormalizedY))
        let p2 = CGPoint(x: cellWidth + centerX, y: graphTop + yInGraph(nextNormalizedY))
        let p3 = CGPoint(x: cellWidth * 2, y: graphTop + yInGraph(nextNormalizedY))

        let (cp1, cp2) = TemperatureGraphGeometry.bezierControlPoints(p0: p0, p1: p1, p2: p2, p3: p3)

        let path = UIBezierPath()
        path.move(to: p1)
        path.addCurve(to: p2, controlPoint1: cp1, controlPoint2: cp2)
        return path
    }

    static func dotCenter(
        cellWidth: CGFloat,
        graphTop: CGFloat,
        graphHeight: CGFloat,
        normalizedY: CGFloat
    ) -> CGPoint {
        let y = graphTop + TemperatureGraphGeometry.dotY(
            normalized: normalizedY,
            graphHeight: graphHeight,
            inset: graphInset
        ) - (WeatherDesignSystem.Graph.Cell.curveLineWidth / 2)
        return CGPoint(x: cellWidth / 2, y: y)
    }
}
