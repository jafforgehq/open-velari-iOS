import Foundation

enum NetworkService {
    private static let dataBaseURL = "https://raw.githubusercontent.com/jafforgehq/openvelari/main"
    private static let siteBaseURL = "https://openvelari.app"

    private static let decoder: JSONDecoder = {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()

    static func fetchLatestIssue() async throws -> Issue {
        try await fetch(dataBaseURL + "/data/latest.json")
    }

    static func fetchIssue(date: String) async throws -> Issue {
        try await fetch(dataBaseURL + "/data/\(date).json")
    }

    static func fetchArchiveIndex() async throws -> ArchiveIndex {
        try await fetch(dataBaseURL + "/data/index.json")
    }

    static func fetchSearchIndex() async throws -> [SearchEntry] {
        try await fetch(siteBaseURL + "/search-index.json")
    }

    private static let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        config.timeoutIntervalForResource = 30
        return URLSession(configuration: config)
    }()

    private static func fetch<T: Decodable>(_ urlString: String) async throws -> T {
        guard let url = URL(string: urlString) else {
            throw NetworkError.invalidURL
        }

        let (data, response) = try await session.data(from: url)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw NetworkError.httpError(statusCode: httpResponse.statusCode)
        }

        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
}

enum NetworkError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case decodingError(Error)
    var errorDescription: String? {
        switch self {
        case .invalidURL: "Invalid URL"
        case .invalidResponse: "Invalid response"
        case .httpError(let code): "Server error (\(code))"
        case .decodingError: "Failed to parse data"
        }
    }
}
