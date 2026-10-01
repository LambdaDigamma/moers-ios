//
//  DefaultPageService.swift
//  
//
//  Created by Lennart Fischer on 11.04.21.
//

import Foundation
import Core
import ModernNetworking

public class DefaultPageService: PageService {

    private let client: any HTTPClient
    
    public init(client: any HTTPClient) {
        self.client = client
    }

    @MainActor
    public convenience init(_ loader: HTTPLoader = URLSessionLoader()) {
        self.init(client: HTTPLoaderClient(loader: loader))
    }
    
    public func show(for pageID: Page.ID, cacheMode: CacheMode = .cached) async throws -> Resource<Page> {
        
        var request = Self.showRequest(pageID: pageID)
        
        request.cachePolicy = cacheMode.policy
        
        let result = await client.load(request)
        
        let posts = try await result.decoding(Resource<Page>.self)
        
        return posts
        
    }
    
    internal static func showRequest(pageID: Page.ID) -> HTTPRequest {
        HTTPRequest(path: Endpoint.show(pageID: pageID).path())
    }

    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}
}

extension DefaultPageService {
    
    nonisolated public enum Endpoint {
        
        case show(pageID: Page.ID)
        
        nonisolated func path() -> String {
            switch self {
                case .show(let id):
                    return "pages/\(id)"
            }
        }
    }
        
}
