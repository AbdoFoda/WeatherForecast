import XCTest
@testable import WeatherCore

final class HTTPClientTests: XCTestCase {
    private let baseURL = URL(string: "https://weather-proxy.example.workers.dev")!
    private let endpoint = Endpoint.currentWeather(lat: 52.52, lon: 13.40)

    private func makeClient(baseURL: URL? = nil) -> HTTPClient {
        let configuration = URLSessionConfiguration.ephemeral
        configuration.protocolClasses = [StubURLProtocol.self]
        return HTTPClient(session: URLSession(configuration: configuration), baseURL: baseURL ?? self.baseURL)
    }

    override func tearDown() {
        StubURLProtocol.handler = nil
        super.tearDown()
    }

    func test_data_returnsBodyOn200() async throws {
        let payload = Data("{\"ok\":true}".utf8)
        StubURLProtocol.handler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, payload)
        }

        let data = try await makeClient().data(for: endpoint)
        XCTAssertEqual(data, payload)
    }

    func test_data_throwsHTTPErrorOnNon2xx() async {
        StubURLProtocol.handler = { request in
            let response = HTTPURLResponse(url: request.url!, statusCode: 503, httpVersion: nil, headerFields: nil)!
            return (response, Data())
        }

        await assertThrows(WeatherError.httpError(statusCode: 503)) {
            try await makeClient().data(for: endpoint)
        }
    }

    func test_data_throwsInvalidURLForNonHTTPSBaseURL() async {
        let client = makeClient(baseURL: URL(string: "http://insecure.example.com")!)
        await assertThrows(WeatherError.invalidURL) {
            try await client.data(for: endpoint)
        }
    }

    func test_data_mapsConnectivityErrorToOffline() async {
        StubURLProtocol.handler = { _ in throw URLError(.notConnectedToInternet) }
        await assertThrows(WeatherError.offline) {
            try await makeClient().data(for: endpoint)
        }
    }

    func test_data_mapsOtherURLErrorsToTransport() async {
        StubURLProtocol.handler = { _ in throw URLError(.badServerResponse) }
        await assertThrows(WeatherError.transport) {
            try await makeClient().data(for: endpoint)
        }
    }

    func test_data_throwsInvalidResponseForNonHTTPResponse() async {
        StubURLProtocol.handler = { request in
            let response = URLResponse(
                url: request.url!,
                mimeType: nil,
                expectedContentLength: 0,
                textEncodingName: nil
            )
            return (response, Data())
        }
        await assertThrows(WeatherError.invalidResponse) {
            try await makeClient().data(for: endpoint)
        }
    }

    private func assertThrows(
        _ expected: WeatherError,
        _ body: () async throws -> Data,
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        do {
            _ = try await body()
            XCTFail("Expected \(expected) to be thrown", file: file, line: line)
        } catch let error as WeatherError {
            XCTAssertEqual(error, expected, file: file, line: line)
        } catch {
            XCTFail("Unexpected error: \(error)", file: file, line: line)
        }
    }
}
