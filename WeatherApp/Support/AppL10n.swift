import Foundation

enum AppL10n {
    static var attribution: String { tr("attribution.openweather") }
    static var cancel: String { tr("common.cancel") }
    static var locationPermissionMessage: String { tr("location.permission.message") }
    static var openSettings: String { tr("location.permission.open_settings") }
    static var simulatorLocationHint: String { tr("location.simulator_hint") }

    private static func tr(_ key: String) -> String {
        String(localized: String.LocalizationValue(key), bundle: .main)
    }
}
