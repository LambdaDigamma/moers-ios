import Foundation

public protocol AppStoreUpdateStatusFetching: Sendable {
    func fetchStatus() async throws -> AppStoreUpdateStatus
}

public struct AppStoreUpdateStatusFetcher: AppStoreUpdateStatusFetching {
    public enum Lookup: Equatable, Sendable {
        case appID(String, countryCode: String? = nil)
        case bundleID(String, countryCode: String? = nil)
    }

    public enum FetchError: LocalizedError, Sendable {
        case missingCurrentVersion
        case missingMetadata
        case invalidLookupURL

        public var errorDescription: String? {
            switch self {
                case .missingCurrentVersion:
                    return "The current app version could not be resolved."
                case .missingMetadata:
                    return "The App Store lookup response did not include app metadata."
                case .invalidLookupURL:
                    return "The App Store lookup URL could not be built."
            }
        }
    }

    private let lookup: Lookup
    private let currentVersionProvider: @Sendable () -> String?
    private let dataLoader: @Sendable (URL) async throws -> Data
    private let decoder: JSONDecoder

    public init(
        lookup: Lookup,
        currentVersionProvider: @escaping @Sendable () -> String? = {
            Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
        },
        urlSession: URLSession = .shared
    ) {
        self.init(
            lookup: lookup,
            currentVersionProvider: currentVersionProvider,
            dataLoader: { url in
                try await urlSession.data(from: url).0
            }
        )
    }

    init(
        lookup: Lookup,
        currentVersionProvider: @escaping @Sendable () -> String?,
        dataLoader: @escaping @Sendable (URL) async throws -> Data,
        decoder: JSONDecoder = JSONDecoder()
    ) {
        self.lookup = lookup
        self.currentVersionProvider = currentVersionProvider
        self.dataLoader = dataLoader
        self.decoder = decoder
    }

    public func fetchStatus() async throws -> AppStoreUpdateStatus {
        guard let currentVersion = currentVersionProvider() else {
            throw FetchError.missingCurrentVersion
        }

        let data = try await dataLoader(try lookupURL())
        let response = try decoder.decode(AppStoreLookupResponse.self, from: data)

        guard let metadata = response.results.first else {
            throw FetchError.missingMetadata
        }

        switch AppVersion.compare(currentVersion, metadata.version) {
            case .orderedDescending:
                return .newerVersionInstalled
            case .orderedSame:
                return .upToDate
            case .orderedAscending:
                return .updateAvailable(
                    AppStoreUpdate(
                        version: metadata.version,
                        storeURL: metadata.trackViewUrl
                    )
                )
        }
    }

    private func lookupURL() throws -> URL {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "itunes.apple.com"
        components.path = "/lookup"

        switch lookup {
            case .appID(let appID, let countryCode):
                components.queryItems = queryItems(primary: URLQueryItem(name: "id", value: appID), countryCode: countryCode)
            case .bundleID(let bundleID, let countryCode):
                components.queryItems = queryItems(primary: URLQueryItem(name: "bundleId", value: bundleID), countryCode: countryCode)
        }

        guard let url = components.url else {
            throw FetchError.invalidLookupURL
        }

        return url
    }

    private func queryItems(primary: URLQueryItem, countryCode: String?) -> [URLQueryItem] {
        var items = [primary]

        if let countryCode, countryCode.isEmpty == false {
            items.append(URLQueryItem(name: "country", value: countryCode))
        }

        return items
    }
}

struct AppStoreLookupResponse: Decodable {
    let results: [AppStoreMetadata]
}

struct AppStoreMetadata: Decodable {
    let version: String
    let trackViewUrl: URL
}

