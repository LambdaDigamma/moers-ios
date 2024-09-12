//
//  RSSLoader.swift
//  Watch Extension
//
//  Created by Lennart Fischer on 10.06.21.
//  Copyright © 2021 Lennart Fischer. All rights reserved.
//

import Foundation
//import NewsWidgets
import Combine
import FeedKit
import UIKit

public class RSSLoader: NewsLoader {
    
    private let session: URLSession
    
    public init(session: URLSession = .shared) {
        self.session = session
    }
    
    public func fetchEntry() -> AnyPublisher<NewsEntry, Error> {
        
        return fetchRSSFeedItems()
            .map({ items in
                items
                    .prefix(4)
                    .map { item in
                        
                        var imageURL: URL?
                        
                        if let enclosure = item.enclosure?.attributes?.url {
                            imageURL = URL(string: enclosure)
                        }
                        
                        return NewsViewModel(
                            topic: nil,
                            headline: item.title ?? "",
                            link: URL(string: item.link ?? "https://tagesschau.de")!,
                            imageURL: imageURL
                        )
                    }
            })
            .flatMap({ [unowned self] (viewModels: [NewsViewModel]) -> AnyPublisher<[NewsViewModel], Error> in
                
                let publishers = viewModels
                    .map({ viewModel -> AnyPublisher<NewsViewModel, Never> in
                        return loadImage(viewModel: viewModel)
                    })
                
                return Publishers.Sequence<[AnyPublisher<NewsViewModel, Never>], Error>(sequence: publishers)
                    .flatMap({ $0 })
                    .collect()
                    .eraseToAnyPublisher()
                
            })
            .map({ newsViewModels in
                return NewsEntry(viewModels: newsViewModels, date: Date())
            })
            .eraseToAnyPublisher()
        
    }
    
    private func loadImage(viewModel: NewsViewModel) -> AnyPublisher<NewsViewModel, Never> {
        
        if let imageURL = viewModel.imageURL {
            var newViewModel = viewModel
            
            return session.dataTaskPublisher(for: imageURL)
                .map(\.data)
                .map({ data in
                    UIImage(data: data) ?? UIImage()
                })
                .replaceError(with: UIImage())
                .map({ image in
                    newViewModel.image = {
                        return image
                    }
                    return newViewModel
                })
                .eraseToAnyPublisher()
            
        } else {
            return Just(viewModel)
                .eraseToAnyPublisher()
        }
        
    }
    
    private func fetchRSSFeedItems() -> AnyPublisher<[RSSFeedItem], Error> {
        
        let feedURL = URL(string: "https://rp-online.de/nrw/staedte/moers/feed.rss")!
        let parser = FeedParser(URL: feedURL)
        
        return Deferred {
            return Future<[RSSFeedItem], Error> { promise in
                parser.parseAsync(queue: DispatchQueue.global(qos: .userInitiated)) { (result) in
                    
                    DispatchQueue.main.async {
                        
                        switch result {
                            case .success(let feed):
                                
                                if let rssFeed = feed.rssFeed {
                                    promise(.success(rssFeed.items ?? []))
                                }
                                
                            case .failure(let error):
                                promise(.failure(error))
                        }
                        
                    }
                }
            }
        }.eraseToAnyPublisher()
        
    }
    
}
