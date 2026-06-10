import CoreGraphics
import Foundation

public enum WeatherConstants {
    public enum Forecast {
        public static let blockInterval: TimeInterval = 3 * 60 * 60
        public static var currentSlotTolerance: TimeInterval { blockInterval / 2 }
    }

    public enum Visibility {
        public static let metersPerKilometer = 1_000
    }

    public enum Wind {
        public static let degreesPerCompassPoint = 22.5
        public static let compassPointCount = 16
    }

    public enum Temperature {
        public static let flatRangePadding: Double = 1
    }

    public enum Icon {
        public static let baseURL = "https://openweathermap.org/img/wn/"
        public static let scaleSuffix = "@2x.png"
        public static let fallbackIconID = "01d"
    }

    public enum DateFormat {
        public static let dayKey = "yyyy-MM-dd"
        public static let dayHeader = "d MMM"
        public static let time = "HH:mm"
    }

    public enum TileLayout {
        public static let rowHeight: CGFloat = 120
        public static let phoneColumnCount = 2
        public static let tabletColumnCount = 3
        public static let largeTabletColumnCount = 4
        public static let tabletMinWidth: CGFloat = 500
        public static let largeTabletMinWidth: CGFloat = 800
    }
}
