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

public class PageViewModel: ObservableObject {
    
    private let pageService: PageService?
    private let pageID: Page.ID
    private var cancellables = Set<AnyCancellable>()
    
    @Published var page: UIResource<Page> = .loading
    @Published var urlRequest: UIResource<URLRequest> = .loading
    
    public init(pageService: PageService?, pageID: Page.ID) {
        self.pageService = pageService
        self.pageID = pageID
    }
    
    public func loadPage() {
        
        if let pageService = pageService {
            
            let pageLoading = pageService.loadPage(for: pageID)
            
            pageLoading.receive(on: DispatchQueue.main).sink { (completion: Subscribers.Completion<Error>) in
                
                switch completion {
                    case .failure(let error):
                        print(error)
                    case .finished:
                        break
                }
                
            } receiveValue: { (page: Page) in
                
                if let slug = page.slug, let url = URL(string: "https://archiv.moers-festival.de/\(slug)") {
                    
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
                
            }.store(in: &cancellables)
            
        }
        
    }
    
}

#endif
