public protocol ThemeStoring: Sendable {
    func loadTheme() -> AppTheme
    func saveTheme(_ theme: AppTheme)
}
