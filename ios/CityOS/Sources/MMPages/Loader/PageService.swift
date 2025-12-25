//
//  PageService.swift
//  
//
//  Created by Lennart Fischer on 11.04.21.
//

import Foundation
import Combine
import ModernNetworking

public protocol PageService {
    
    func loadPage(for pageID: Page.ID) -> AnyPublisher<Page, Error>
    
    func show(for pageID: Page.ID, cacheMode: CacheMode) async throws -> Resource<Page>
    
}
