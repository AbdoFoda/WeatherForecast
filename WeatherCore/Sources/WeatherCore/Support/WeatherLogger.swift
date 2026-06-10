import Foundation

public enum WeatherLogger {
    public static func log(_ message: String) {
        #if DEBUG
        print("[Weather] \(message)")
        #endif
    }

    public static func log(_ error: Error) {
        log(String(describing: error))
    }
}
