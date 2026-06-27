//
//  PageViewModel.swift
//  
//
//  Created by Lennart Fischer on 16.04.21.
//

import Foundation

#if canImport(UIKit)

import UIKit
import ModernNetworking
import Combine
import SwiftUI

@Observable
public class PageViewModel {
    
    private let pageService: PageService?
    private let pageID: Page.ID
    @ObservationIgnored
    private var cancellables = Set<AnyCancellable>()
    
    var page: UIResource<Page> = .loading
    var urlRequest: UIResource<URLRequest> = .loading
    
    public init(pageService: PageService?, pageID: Page.ID) {
        self.pageService = pageService
        self.pageID = pageID
    }
    
    public func loadPage() async {
        
        if let pageService = pageService {
            
            do {
                
                let resource = try await pageService.show(for: pageID, cacheMode: .cached)
                let page = resource.data
                
                if let slug = page.slug, let url = URL(string: "https://moers.app/\(slug)") {
                    
                    if var components = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                        
                        let queryStandalone = URLQueryItem(name: "standalone", value: "true")
                        components.queryItems = [queryStandalone]
                        
                        if let modifiedURL = components.url {
                            var request = URLRequest(url: modifiedURL)
                            request.addValue("de,en-US;q=0.7,en;q=0.3", forHTTPHeaderField: "Accept-Language")
                            
                            self.urlRequest = .success(request)
                        }
                        
                    }
                    
                }
                
                self.page = .success(page)
                
            } catch {
                print(error)
            }
            
        }
        
    }
    
}

#endif
