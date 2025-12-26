//
//  Container+NewsService.swift
//  NewsFeature
//
//  Created for Factory migration
//

import Foundation
import Factory

public extension Container {
    
    var newsService: Factory<NewsService> {
        self {
            StaticNewsService()
        }
    }
    
}
