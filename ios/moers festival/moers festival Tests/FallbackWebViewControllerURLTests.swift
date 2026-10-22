import Foundation
import UIKit
import WebKit
import XCTest
@testable import moers_festival

@MainActor
final class FallbackWebViewControllerURLTests: XCTestCase {
    func testKeepsQueryItemsAndFragment() async throws {
        let url = try await loadedURL("https://example.invalid/tickets?lang=en&page=2#offers")
        let components = try XCTUnwrap(URLComponents(url: url, resolvingAgainstBaseURL: false))

        XCTAssertEqual(components.queryItems, [
            URLQueryItem(name: "lang", value: "en"),
            URLQueryItem(name: "page", value: "2"),
            URLQueryItem(name: "standalone", value: "true")
        ])
        XCTAssertEqual(components.fragment, "offers")
    }

    func testReplacesOnlyStandaloneIncludingDuplicateValues() async throws {
        let url = try await loadedURL("https://example.invalid/search?q=jazz&standalone=false&tag=a&tag=b&standalone=0")
        let components = try XCTUnwrap(URLComponents(url: url, resolvingAgainstBaseURL: false))

        XCTAssertEqual(components.queryItems, [
            URLQueryItem(name: "q", value: "jazz"),
            URLQueryItem(name: "tag", value: "a"),
            URLQueryItem(name: "tag", value: "b"),
            URLQueryItem(name: "standalone", value: "true")
        ])
    }

    func testKeepsEncodedQueryValues() async throws {
        let url = try await loadedURL("https://example.invalid/search?q=C%2B%2B&next=%2Ftickets%3Fday%3D2&flag&empty=&%73tandalone=false")
        let components = try XCTUnwrap(URLComponents(url: url, resolvingAgainstBaseURL: false))

        XCTAssertEqual(components.percentEncodedQuery, "q=C%2B%2B&next=%2Ftickets%3Fday%3D2&flag&empty=&standalone=true")
    }

    func testAddsStandaloneWhenThereIsNoQuery() async throws {
        let url = try await loadedURL("https://example.invalid/info#details")
        XCTAssertEqual(url.absoluteString, "https://example.invalid/info?standalone=true#details")
    }

    private func loadedURL(_ value: String) async throws -> URL {
        let controller = FallbackWebViewController(url: try XCTUnwrap(URL(string: value)))
        let webView = FallbackWebViewRequestSpy(frame: .zero, configuration: WKWebViewConfiguration())
        webView.translatesAutoresizingMaskIntoConstraints = false
        controller.webkitView = webView
        controller.loadViewIfNeeded()
        return try XCTUnwrap(webView.request?.url)
    }
}
