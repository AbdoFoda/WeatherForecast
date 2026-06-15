import UIKit
import WeatherCore

extension Notification.Name {
    static let themeDidChange = Notification.Name("weather.themeDidChange")
}

@MainActor
final class ThemeManager {
    static let shared = ThemeManager()

    private var store: any ThemeStoring
    private(set) var current: AppTheme
    private(set) var palette: ThemePalette

    private init(store: any ThemeStoring = ThemeStore()) {
        self.store = store
        let theme = store.loadTheme()
        self.current = theme
        self.palette = ThemePalette.palette(for: theme)
    }

    func configure(store: any ThemeStoring) {
        self.store = store
        apply(store.loadTheme(), persist: false)
    }

    func apply(_ theme: AppTheme, persist: Bool = true) {
        current = theme
        palette = ThemePalette.palette(for: theme)
        if persist {
            store.saveTheme(theme)
        }
        NotificationCenter.default.post(name: .themeDidChange, object: nil)
    }

    var allThemes: [ThemePalette] {
        AppTheme.allCases.map(ThemePalette.palette(for:))
    }
}
