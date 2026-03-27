import Testing
import Foundation
@testable import Velari

@Suite("Network Errors")
struct NetworkErrorTests {
    @Test func invalidURLDescription() {
        let error = NetworkError.invalidURL
        #expect(error.errorDescription == "Invalid URL")
    }

    @Test func invalidResponseDescription() {
        let error = NetworkError.invalidResponse
        #expect(error.errorDescription == "Invalid response")
    }

    @Test func httpErrorIncludesStatusCode() {
        let error = NetworkError.httpError(statusCode: 404)
        #expect(error.errorDescription == "Server error (404)")
    }

    @Test func decodingErrorDescription() {
        let error = NetworkError.decodingError(NSError(domain: "", code: 0))
        #expect(error.errorDescription == "Failed to parse data")
    }
}
