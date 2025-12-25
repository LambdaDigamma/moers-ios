//
//  MockPageService.swift
//  
//
//  Created by Lennart Fischer on 08.04.23.
//

import Foundation
import Combine
import ModernNetworking

public class MockPageService: PageService {
    
    private let result: Result<Page, Error>
    
    public init(result: Result<Page, Error>) {
        self.result = result
    }
    
    public func loadPage(for pageID: Page.ID) -> AnyPublisher<Page, Error> {
        
        switch result {
            case .success(let success):
                return Just(success).setFailureType(to: Error.self).eraseToAnyPublisher()
            case .failure(let failure):
                return Fail(error: failure).eraseToAnyPublisher()
        }
        
    }
    
    public func show(for pageID: Page.ID, cacheMode: CacheMode = .cached) async throws -> Resource<Page> {
        
        switch result {
            case .success(let success):
                return Resource(data: success)
            case .failure(let failure):
                throw failure
        }
        
    }
    
}
