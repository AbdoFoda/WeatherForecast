import XCTest
@testable import WeatherCore

@MainActor
final class AddLocationViewModelTests: XCTestCase {
    func test_setQuery_belowMinimumLength_clearsResults() async {
        let provider = MockLocationSearchProvider()
        provider.results = [LocationModel(id: "1", name: "London", lat: 51.5, lon: -0.12, country: "GB")]
        let sut = AddLocationViewModel(searchProvider: provider)

        await sut.setQuery("L")

        XCTAssertTrue(sut.state.results.isEmpty)
        XCTAssertFalse(sut.state.isSearching)
        XCTAssertEqual(provider.searchCallCount, 0)
    }

    func test_setQuery_publishesSearchResults() async {
        let london = LocationModel(id: "1", name: "London", lat: 51.5, lon: -0.12, country: "GB")
        let provider = MockLocationSearchProvider()
        provider.results = [london]
        let sut = AddLocationViewModel(searchProvider: provider)

        var published: AddLocationViewState?
        sut.onStateChange = { published = $0 }

        await sut.setQuery("London")

        XCTAssertEqual(published?.results, [london])
        XCTAssertFalse(published?.isSearching ?? true)
        XCTAssertEqual(provider.searchCallCount, 1)
    }

    func test_setQuery_failure_clearsResults() async {
        let provider = MockLocationSearchProvider()
        provider.error = TestError.failed
        let sut = AddLocationViewModel(searchProvider: provider)

        await sut.setQuery("Paris")

        XCTAssertTrue(sut.state.results.isEmpty)
        XCTAssertFalse(sut.state.isSearching)
    }

    func test_result_returnsLocationAtIndex() async {
        let london = LocationModel(id: "1", name: "London", lat: 51.5, lon: -0.12, country: "GB")
        let provider = MockLocationSearchProvider()
        provider.results = [london]
        let sut = AddLocationViewModel(searchProvider: provider)

        await sut.setQuery("London")

        XCTAssertEqual(sut.result(at: 0), london)
        XCTAssertNil(sut.result(at: 5))
    }

    private enum TestError: Error {
        case failed
    }
}
