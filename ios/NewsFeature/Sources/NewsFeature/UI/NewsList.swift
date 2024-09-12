//
//  NewsList.swift
//  
//
//  Created by Lennart Fischer on 01.02.22.
//

import SwiftUI
import FeedKit
import Core

public struct NewsList: View {
    
    @StateObject var viewModel: NewsViewModel
    
    public var onShowArticle: (RSSFeedItem) -> Void
    
    public init(
        newsService: NewsService,
        onShowArticle: @escaping (RSSFeedItem) -> Void
    ) {
        self._viewModel = StateObject(
            wrappedValue: NewsViewModel(newsService: newsService)
        )
        self.onShowArticle = onShowArticle
    }
    
    public var body: some View {
        
        GeometryReader { proxy in
            
            ScrollView {
                LazyVGrid(columns: columns(for: proxy.size), spacing: 16) {
                    
                    ForEach(viewModel.newsItems, id: \.self) { feedItem in
                        
                        Button(action: {
                            onShowArticle(feedItem)
                        }) {
                            
                            NewsItemPanel(
                                headline: feedItem.title ?? "",
                                source: feedItem.source?.value ?? "",
                                publishedAt: feedItem.pubDate ?? Date(),
                                imageURL: feedItem.enclosure?.attributes?.url ?? nil
                            )
                            
                        }
                        .buttonStyle(BasicPanelStyle())
                        
                    }
                    
                }
                .padding()
            }
            
        }
        .onAppear {
            viewModel.load()
        }
    }
    
    private func columns(for size: CGSize) -> [GridItem] {
        
        return Array(
            repeating: GridItem(.flexible(minimum: 100, maximum: 600),
                                spacing: 16,
                                alignment: .topTrailing),
            count: size.width > 1000 ? 3 : (size.width > 600 ? 2 : 1)
        )
        
    }
    
}

struct NewsList_Previews: PreviewProvider {
    
    static let service = DefaultNewsService()
    
    static var previews: some View {
        NavigationView {
            NewsList(newsService: service) { _ in
                
            }
        }
            .preferredColorScheme(.dark)
    }
}
