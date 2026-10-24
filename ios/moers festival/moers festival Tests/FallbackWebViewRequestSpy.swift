import Foundation
import WebKit

@MainActor
final class FallbackWebViewRequestSpy: WKWebView {
    private(set) var request: URLRequest?

    override func load(_ request: URLRequest) -> WKNavigation? {
        self.request = request
        return nil
    }
}
