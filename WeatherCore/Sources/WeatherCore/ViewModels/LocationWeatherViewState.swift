public enum LocationWeatherViewState: Sendable {
    case loading
    case loaded(LocationWeatherDisplayData)
    case error(String)
    case locationPermissionDenied
}
