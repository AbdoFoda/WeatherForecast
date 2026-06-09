import XCTest
@testable import WeatherCore

final class EndpointTests: XCTestCase {
    private let base = URL(string: "https://weather-proxy.example.workers.dev")!

    func test_currentWeather_buildsCorrectURL() throws {
        let endpoint = Endpoint.currentWeather(lat: 52.5200, lon: 13.4050)
        let url = try endpoint.url(baseURL: base)
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)!

        XCTAssertEqual(components.path, "/current")
        XCTAssertTrue(components.queryItems!.contains(URLQueryItem(name: "lat", value: "52.5200")))
        XCTAssertTrue(components.queryItems!.contains(URLQueryItem(name: "lon", value: "13.4050")))
        XCTAssertNil(components.queryItems!.first(where: { $0.name == "appid" }))
    }

    func test_forecast_includesCntParameter() throws {
        let endpoint = Endpoint.forecast(lat: 52.5200, lon: 13.4050, count: 40)
        let url = try endpoint.url(baseURL: base)
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)!

        XCTAssertEqual(components.path, "/forecast")
        XCTAssertTrue(components.queryItems!.contains(URLQueryItem(name: "cnt", value: "40")))
        XCTAssertNil(components.queryItems!.first(where: { $0.name == "appid" }))
    }

    func test_airPollution_buildsCorrectPath() throws {
        let endpoint = Endpoint.airPollution(lat: 52.5200, lon: 13.4050)
        let url = try endpoint.url(baseURL: base)
        XCTAssertTrue(url.absoluteString.contains("/air"))
        XCTAssertNil(URLComponents(url: url, resolvingAgainstBaseURL: false)!
            .queryItems!.first(where: { $0.name == "appid" }))
    }

    func test_geocodingDirect_encodesQueryString() throws {
        let endpoint = Endpoint.geocodingDirect(query: "New York", limit: 3)
        let url = try endpoint.url(baseURL: base)
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)!

        XCTAssertEqual(components.path, "/geo/direct")
        XCTAssertTrue(components.queryItems!.contains(URLQueryItem(name: "q", value: "New York")))
        XCTAssertTrue(components.queryItems!.contains(URLQueryItem(name: "limit", value: "3")))
    }
}
