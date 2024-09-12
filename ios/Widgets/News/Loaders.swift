//
//  NewsLoader.swift
//  
//
//  Created by Lennart Fischer on 10.06.21.
//

import Foundation
import Combine
import UIKit

public protocol NewsLoader {
    
    func fetchEntry() -> AnyPublisher<NewsEntry, Error>
    
}

public protocol ImageLoader {
    
    func load(from: URL) -> AnyPublisher<UIImage, Error>
    
}

extension ImageLoader {
    
    func load(from url: URL, with session: URLSession = .shared) -> AnyPublisher<UIImage, Error> {
        
        return session.dataTaskPublisher(for: url)
            .map(\.data)
            .map({ data in
                UIImage(data: data) ?? UIImage()
            })
            .mapError({ failure in
                failure
            })
            .eraseToAnyPublisher()
        
    }
    
}

//public class RSSLoader: NewsLoader {
//
//    private let session: URLSession
//    private let sortedBy: ([NewsViewModel]) -> [NewsViewModel]
//
//    public init(
//        session: URLSession = .shared,
//        sortedBy: @escaping ([NewsViewModel]) -> [NewsViewModel] = RSSLoader.defaultSortingAction
//    ) {
//        self.session = session
//        self.sortedBy = sortedBy
//    }
//
//    public func fetchEntry() -> AnyPublisher<NewsEntry, Error> {
//
//
//
//    }
//
//    public static func defaultSortingAction(news: [NewsViewModel]) -> [NewsViewModel] {
//        return news
//    }
//
//}
