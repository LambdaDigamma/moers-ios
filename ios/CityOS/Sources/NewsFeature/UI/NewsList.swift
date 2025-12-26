//
//  NewsList.swift
//  
//
//  Created by Lennart Fischer on 01.02.22.
//

import SwiftUI
import FeedKit
import Core
import Factory

public struct NewsList: View {
    
    @StateObject var viewModel: NewsViewModel
    
    public var onShowArticle: (RSSFeedItem) -> Void
    
    public init(
        onShowArticle: @escaping (RSSFeedItem) -> Void
    ) {
        self._viewModel = StateObject(wrappedValue: NewsViewModel())
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
                            
//                            Text(feedItem.title ?? "")

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
            .background(ApplicationTheme.current.dashboardBackground)
            
        }
        .task {
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

#Preview {
    
    Container.shared.newsService.register {
        DefaultNewsService()
    }
    
    return NavigationView {
        NewsList() { _ in
            
        }
    }
    .preferredColorScheme(.dark)
    
}
