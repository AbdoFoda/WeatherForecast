import XCTest
@testable import WeatherCore

final class EndpointTests: XCTestCase {
    private let base = URL(string: "https://weather-proxy.example.workers.dev")!

    func test_currentWeather_buildsCorrectURL() throws {
        let endpoint = Endpoint.currentWeather(lat: 52.5200, lon: 13.4050)
        let url = try endpoint.url(baseURL: base)
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)!

        XCTAssertEqual(components.path, "/\(WeatherAPI.Route.current.rawValue)")
        XCTAssertTrue(components.queryItems!.contains(
            URLQueryItem(name: WeatherAPI.QueryKey.lat.rawValue, value: "52.5200")
        ))
        XCTAssertTrue(components.queryItems!.contains(
            URLQueryItem(name: WeatherAPI.QueryKey.lon.rawValue, value: "13.4050")
        ))
        XCTAssertNil(components.queryItems!.first(where: { $0.name == "appid" }))
    }

    func test_forecast_includesCntParameter() throws {
        let endpoint = Endpoint.forecast(lat: 52.5200, lon: 13.4050, count: 40)
        let url = try endpoint.url(baseURL: base)
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)!

        XCTAssertEqual(components.path, "/\(WeatherAPI.Route.forecast.rawValue)")
        XCTAssertTrue(components.queryItems!.contains(
            URLQueryItem(name: WeatherAPI.QueryKey.cnt.rawValue, value: "40")
        ))
        XCTAssertNil(components.queryItems!.first(where: { $0.name == "appid" }))
    }

    func test_airPollution_buildsCorrectPath() throws {
        let endpoint = Endpoint.airPollution(lat: 52.5200, lon: 13.4050)
        let url = try endpoint.url(baseURL: base)
        XCTAssertTrue(url.absoluteString.contains("/\(WeatherAPI.Route.airPollution.rawValue)"))
        XCTAssertNil(URLComponents(url: url, resolvingAgainstBaseURL: false)!
            .queryItems!.first(where: { $0.name == "appid" }))
    }

    func test_geocodingDirect_encodesQueryString() throws {
        let endpoint = Endpoint.geocodingDirect(query: "New York", limit: 3)
        let url = try endpoint.url(baseURL: base)
        let components = URLComponents(url: url, resolvingAgainstBaseURL: false)!

        XCTAssertEqual(components.path, "/\(WeatherAPI.Route.geocodingDirect.rawValue)")
        XCTAssertTrue(components.queryItems!.contains(
            URLQueryItem(name: WeatherAPI.QueryKey.q.rawValue, value: "New York")
        ))
        XCTAssertTrue(components.queryItems!.contains(
            URLQueryItem(name: WeatherAPI.QueryKey.limit.rawValue, value: "3")
        ))
    }
}
