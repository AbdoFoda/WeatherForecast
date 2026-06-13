import XCTest
import WeatherCore
@testable import WeatherApp

@MainActor
final class AppCoordinatorTests: XCTestCase {
    func test_init_retainsInjectedWeatherService() {
        let mockService = MockWeatherServiceForApp()
        let sut = AppCoordinator(weatherService: mockService)
        XCTAssertNotNil(sut)
    }

    func test_live_loadsBaseURLFromMainBundle() {
        let sut = AppCoordinator.live()
        XCTAssertNotNil(sut)
    }

    func test_start_loadsLocationsAndRequestsDeviceLocation() {
        let mockLocations = MockLocationsViewModel()
        let mockSummaries = MockLocationSummariesViewModel()
        let mockDevice = MockDeviceLocationManager()
        let sut = AppCoordinator(
            weatherService: MockWeatherServiceForApp(),
            locationsStore: MockSavedLocationsStore(),
            deviceLocationManager: mockDevice,
            makeLocationsViewModel: { _ in mockLocations },
            makeSummariesViewModel: { _ in mockSummaries }
        )

        sut.start(window: UIWindow())

        XCTAssertEqual(mockLocations.loadCallCount, 1)
        XCTAssertGreaterThanOrEqual(mockDevice.requestLocationCallCount, 1)
        XCTAssertTrue(mockDevice.hasObserver(sut))
    }

    func test_start_refreshesSummariesFromInjectedStore() {
        let paris = LocationModel(id: "paris", name: "Paris", lat: 48.85, lon: 2.35, country: "FR")
        let mockStore = MockSavedLocationsStore(locations: [paris], selectionID: "paris")
        let mockSummaries = MockLocationSummariesViewModel()
        let sut = AppCoordinator(
            weatherService: MockWeatherServiceForApp(),
            locationsStore: mockStore,
            deviceLocationManager: MockDeviceLocationManager(),
            makeSummariesViewModel: { _ in mockSummaries }
        )

        sut.start(window: UIWindow())

        let requestedIDs = mockSummaries.refreshedRequests.flatMap { $0.map(\.id) }
        XCTAssertTrue(requestedIDs.contains("paris"))
    }
}
