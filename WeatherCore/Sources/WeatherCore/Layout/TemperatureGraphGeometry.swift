import CoreGraphics

public enum TemperatureGraphGeometry {
    public static func normalizedDotY(temperature: Double, minTemp: Double, maxTemp: Double) -> CGFloat {
        guard maxTemp > minTemp else { return 0.5 }
        return CGFloat(1.0 - ((temperature - minTemp) / (maxTemp - minTemp)))
    }

    public static func bezierControlPoints(
        p0: CGPoint, p1: CGPoint, p2: CGPoint, p3: CGPoint
    ) -> (cp1: CGPoint, cp2: CGPoint) {
        let cp1 = CGPoint(
            x: p1.x + (p2.x - p0.x) / 6.0,
            y: p1.y + (p2.y - p0.y) / 6.0
        )
        let cp2 = CGPoint(
            x: p2.x - (p3.x - p1.x) / 6.0,
            y: p2.y - (p3.y - p1.y) / 6.0
        )
        return (cp1, cp2)
    }

    public static func dotY(normalized: CGFloat, graphHeight: CGFloat, inset: CGFloat) -> CGFloat {
        inset + normalized * max(0, graphHeight - inset * 2)
    }
}
