import Foundation

enum ProxyConfigurationLoader {
    enum LoaderError: Error, Equatable {
        case missingPlist
        case missingKey
        case invalidURL
    }

    static let baseURLKey = "WeatherProxyBaseURL"

    static func loadBaseURL(
        bundle: Bundle = .main,
        resourceName: String = "Config"
    ) throws -> URL {
        guard let configURL = bundle.url(forResource: resourceName, withExtension: "plist") else {
            throw LoaderError.missingPlist
        }

        let data = try Data(contentsOf: configURL)
        guard let plist = try PropertyListSerialization.propertyList(from: data, format: nil) as? [String: Any],
              let baseURLString = plist[baseURLKey] as? String else {
            throw LoaderError.missingKey
        }

        guard let baseURL = URL(string: baseURLString) else {
            throw LoaderError.invalidURL
        }

        return baseURL
    }
}
