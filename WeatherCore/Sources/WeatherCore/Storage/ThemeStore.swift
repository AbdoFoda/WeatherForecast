import Foundation

public struct ThemeStore: ThemeStoring, Sendable {
    private let defaultsSuiteName: String?
    private let themeKey: String

    public init(
        defaultsSuiteName: String? = nil,
        themeKey: String = "weather.app_theme"
    ) {
        self.defaultsSuiteName = defaultsSuiteName
        self.themeKey = themeKey
    }

    public func loadTheme() -> AppTheme {
        guard let rawValue = defaults.string(forKey: themeKey),
              let theme = AppTheme(rawValue: rawValue) else {
            return .default
        }
        return theme
    }

    public func saveTheme(_ theme: AppTheme) {
        defaults.set(theme.rawValue, forKey: themeKey)
    }

    private var defaults: UserDefaults {
        if let defaultsSuiteName, let suite = UserDefaults(suiteName: defaultsSuiteName) {
            return suite
        }
        return .standard
    }
}
