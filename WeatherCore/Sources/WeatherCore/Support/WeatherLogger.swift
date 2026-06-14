import Foundation
import os

public enum WeatherLogger {
    private static let logger = Logger(subsystem: "com.weatherapp.weathercore", category: "diagnostics")

    public static func log(_ message: String) {
        logger.error("\(message, privacy: .public)")
    }

    public static func log(_ error: Error) {
        log(String(reflecting: type(of: error)))
    }
}
