//
//  PageService.swift
//  
//
//  Created by Lennart Fischer on 11.04.21.
//

import Foundation
import ModernNetworking

public protocol PageService {
    
    func show(for pageID: Page.ID, cacheMode: CacheMode) async throws -> Resource<Page>
    
}
