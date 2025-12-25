//
//  DefaultPageService.swift
//  
//
//  Created by Lennart Fischer on 11.04.21.
//

import Foundation
import Combine
import ModernNetworking

public class DefaultPageService: PageService {
    
    private let loader: HTTPLoader
    
    public init(_ loader: HTTPLoader = URLSessionLoader()) {
        self.loader = loader
    }
    
    public func loadPage(for pageID: Page.ID) -> AnyPublisher<Page, Error> {
        
        let request = Self.showRequest(pageID: pageID)
        
        return Deferred {
            Future { promise in
                self.loader.load(request) { (result) in
                    promise(result)
                }
            }
        }
        .eraseToAnyPublisher()
        .compactMap { $0.body }
        .decode(type: Resource<Page>.self, decoder: Page.decoder)
        .map({
            return $0.data
        })
        .eraseToAnyPublisher()
        
    }
    
    public func show(for pageID: Page.ID, cacheMode: CacheMode = .cached) async throws -> Resource<Page> {
        
        var request = Self.showRequest(pageID: pageID)
        
        request.cachePolicy = cacheMode.policy
        
        let result = await loader.load(request)
        
        let posts = try await result.decoding(Resource<Page>.self)
        
        return posts
        
    }
    
    internal static func showRequest(pageID: Page.ID) -> HTTPRequest {
        HTTPRequest(path: Endpoint.show(pageID: pageID).path())
    }
    
}

extension DefaultPageService {
    
    public enum Endpoint {
        
        case show(pageID: Page.ID)
        
        func path() -> String {
            switch self {
                case .show(let id):
                    return "pages/\(id)"
            }
        }
    }
        
}
