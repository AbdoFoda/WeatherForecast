public enum UserNotice: Sendable, Equatable {
    case offline
}

public enum LocationWeatherViewState: Sendable {
    case loading
    case loaded(LocationWeatherDisplayData, notice: UserNotice?)
    case unavailable(notice: UserNotice?)
    case locationPermissionDenied
}
