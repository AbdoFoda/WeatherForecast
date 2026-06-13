import XCTest
import Synchronization
@testable import WeatherCore

@MainActor
final class LocationSummariesViewModelTests: XCTestCase {
    private func request(_ id: String, lat: Double = 52.52, lon: Double = 13.40) -> LocationSummaryRequest {
        LocationSummaryRequest(id: id, lat: lat, lon: lon)
    }

    private func waitBriefly() async {
        try? await Task.sleep(nanoseconds: 120_000_000)
    }

    func test_refresh_fetchesAndPublishesSummaries() async {
        let service = MockSummaryWeatherService()
        let sut = LocationSummariesViewModel(weatherService: service)

        let published = expectation(description: "onChange")
        sut.onChange = { summaries in
            if summaries["berlin"] != nil { published.fulfill() }
        }

        sut.refresh([request("berlin")])

        await fulfillment(of: [published], timeout: 2)
        XCTAssertNotNil(sut.summaries["berlin"])
        XCTAssertEqual(service.callCount, 1)
    }

    func test_refresh_skipsAlreadyLoadedIDs() async {
        let service = MockSummaryWeatherService()
        let sut = LocationSummariesViewModel(weatherService: service)

        let published = expectation(description: "onChange")
        sut.onChange = { summaries in
            if summaries["berlin"] != nil { published.fulfill() }
        }
        sut.refresh([request("berlin")])
        await fulfillment(of: [published], timeout: 2)

        service.resetCallCount()
        sut.refresh([request("berlin")])
        await waitBriefly()

        XCTAssertEqual(service.callCount, 0)
    }

    func test_refresh_dedupesInFlightRequests() async {
        let service = MockSummaryWeatherService()
        let sut = LocationSummariesViewModel(weatherService: service)

        let published = expectation(description: "onChange")
        sut.onChange = { summaries in
            if summaries["berlin"] != nil { published.fulfill() }
        }

        sut.refresh([request("berlin")])
        sut.refresh([request("berlin")])

        await fulfillment(of: [published], timeout: 2)
        await waitBriefly()
        XCTAssertEqual(service.callCount, 1)
    }

    func test_failedFetch_blocksImmediateRetry() async {
        let service = MockSummaryWeatherService()
        service.shouldFail = true
        let sut = LocationSummariesViewModel(weatherService: service)

        let firstFetch = expectation(description: "first fetch")
        service.fetchExpectation = firstFetch
        sut.refresh([request("berlin")])
        await fulfillment(of: [firstFetch], timeout: 2)
        await waitBriefly()

        service.fetchExpectation = nil
        service.resetCallCount()
        sut.refresh([request("berlin")])
        await waitBriefly()

        XCTAssertNil(sut.summaries["berlin"])
        XCTAssertEqual(service.callCount, 0)
    }

    func test_reload_forcesRefetchForLoadedID() async {
        let service = MockSummaryWeatherService()
        let sut = LocationSummariesViewModel(weatherService: service)

        let firstLoad = expectation(description: "first load")
        sut.onChange = { summaries in
            if summaries["berlin"] != nil { firstLoad.fulfill() }
        }
        sut.refresh([request("berlin")])
        await fulfillment(of: [firstLoad], timeout: 2)

        service.resetCallCount()
        let reloaded = expectation(description: "reloaded")
        sut.onChange = { summaries in
            if summaries["berlin"] != nil { reloaded.fulfill() }
        }
        sut.reload([request("berlin")])

        await fulfillment(of: [reloaded], timeout: 2)
        XCTAssertEqual(service.callCount, 1)
    }

    func test_reload_clearsRetryBlockAfterFailure() async {
        let service = MockSummaryWeatherService()
        service.shouldFail = true
        let sut = LocationSummariesViewModel(weatherService: service)

        let firstFetch = expectation(description: "failing fetch")
        service.fetchExpectation = firstFetch
        sut.refresh([request("berlin")])
        await fulfillment(of: [firstFetch], timeout: 2)
        await waitBriefly()

        service.fetchExpectation = nil
        service.shouldFail = false
        service.resetCallCount()

        let recovered = expectation(description: "recovered")
        sut.onChange = { summaries in
            if summaries["berlin"] != nil { recovered.fulfill() }
        }
        sut.reload([request("berlin")])

        await fulfillment(of: [recovered], timeout: 2)
        XCTAssertNotNil(sut.summaries["berlin"])
        XCTAssertEqual(service.callCount, 1)
    }
}

private final class MockSummaryWeatherService: WeatherServiceProtocol, @unchecked Sendable {
    private struct State {
        var shouldFail = false
        var callCount = 0
    }

    private let state = Mutex(State())
    var fetchExpectation: XCTestExpectation?

    var shouldFail: Bool {
        get { state.withLock { $0.shouldFail } }
        set { state.withLock { $0.shouldFail = newValue } }
    }

    var callCount: Int {
        state.withLock { $0.callCount }
    }

    func resetCallCount() {
        state.withLock { $0.callCount = 0 }
    }

    func fetchCurrentWeather(lat: Double, lon: Double) async throws -> CurrentWeatherResponse {
        let fail = state.withLock { state -> Bool in
            state.callCount += 1
            return state.shouldFail
        }
        fetchExpectation?.fulfill()
        if fail { throw WeatherError.invalidResponse }
        return CurrentWeatherResponse(
            coord: Coordinate(lat: lat, lon: lon),
            weather: [WeatherCondition(id: 800, main: "Clear", description: "clear sky", icon: "01d")],
            main: MainWeather(temp: 20, feelsLike: 20, tempMin: 15, tempMax: 25, pressure: 1013, seaLevel: nil, grndLevel: nil, humidity: 50),
            visibility: nil,
            wind: nil,
            clouds: nil,
            rain: nil,
            snow: nil,
            dt: 0,
            sys: Sys(type: nil, id: nil, country: "DE", sunrise: 0, sunset: 0),
            timezone: 0,
            id: 1,
            name: "Berlin"
        )
    }

    func fetchForecast(lat: Double, lon: Double) async throws -> ForecastResponse {
        throw WeatherError.invalidResponse
    }

    func fetchAirPollution(lat: Double, lon: Double) async throws -> AirPollutionResponse {
        throw WeatherError.invalidResponse
    }
}
