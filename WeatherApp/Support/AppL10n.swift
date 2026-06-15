import Foundation

enum AppL10n {
    static var attribution: String { tr("attribution.openweather") }
    static var cancel: String { tr("common.cancel") }
    static var updating: String { tr("common.updating") }
    static var locationPermissionMessage: String { tr("location.permission.message") }
    static var openSettings: String { tr("location.permission.open_settings") }
    static var simulatorLocationHint: String { tr("location.simulator_hint") }
    static var done: String { tr("common.done") }
    static var settingsTitle: String { tr("settings.title") }
    static var settingsThemeHeader: String { tr("settings.theme.header") }
    static var themeMagic: String { tr("theme.magic") }
    static var themeOcean: String { tr("theme.ocean") }
    static var themeSunset: String { tr("theme.sunset") }
    static var themeForest: String { tr("theme.forest") }
    static var themeMidnight: String { tr("theme.midnight") }

    private static func tr(_ key: String) -> String {
        String(localized: String.LocalizationValue(key), bundle: .main)
    }
}
