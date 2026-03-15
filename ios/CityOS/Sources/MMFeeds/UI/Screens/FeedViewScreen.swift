//
//  FeedViewScreen.swift
//  
//
//  Created by Lennart Fischer on 11.01.21.
//

import SwiftUI
import ModernNetworking
import Cache
import Factory

public struct FeedViewScreen: View {
    
    @ObservedObject var viewModel: FeedPostListViewModel
    
    @State var screenSize: CGSize = .zero
    
    public let showPost: ((Post.ID) -> Void)
    
    public init(viewModel: FeedPostListViewModel, showPost: @escaping (Post.ID) -> Void) {
        self.viewModel = viewModel
        self.showPost = showPost
    }
    
    public var body: some View {
        
        ZStack {
            
            viewModel.items.hasResource { (items: [Post]) in
                success(items: items)
            }
            
            viewModel.items.isLoading {
                
                ProgressView()
                    .progressViewStyle(.circular)
                
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .task {
            await viewModel.reload()
//            if viewModel.items.isEmpty {
//                viewModel.loadCurrentFeed()
//            }
        }
        
    }
    
    @ViewBuilder
    private func success(items: [Post]) -> some View {
        
        ScrollView {
            
            let columns = self.columnCount(for: screenSize.width)
            
            LazyVGrid(columns: columns, spacing: 20) {
                
                ForEach(items) { post in
                    
                    if post.extras?.type == "instagram" {
                        InstagramPostView(post: post, showPost: { showPost($0.id) })
                    } else {
                        BigNewsFeedView(post: post, showPost: { showPost($0.id) })
                    }

//                        .task {
//                            if viewModel.items.last == post {
//                                viewModel.loadNextPosts()
//                            }
//                        }

                }
                
            }
            .padding(20)
            
        }
        .onGeometryChange(for: CGSize.self) { proxy in
            proxy.size
        } action: { newValue in
            self.screenSize = newValue
        }

        
    }
    
    private func columnCount(for width: CGFloat) -> [GridItem] {
        if width > 600 {
//            return Array(repeating: GridItem(.adaptive(minimum: 150), spacing: 10), count: 3)
            return Array(repeating: GridItem(.flexible(), spacing: 12, alignment: .top), count: 3)
        } else if width > 500 {
            return Array(repeating: GridItem(.flexible(), spacing: 12, alignment: .top), count: 2)
        } else {
            return Array(repeating: GridItem(.flexible(), spacing: 12, alignment: .top), count: 1)
//            return [GridItem(.adaptive(minimum: 150), spacing: 10)]
        }
    }

    
}

#Preview {
    
    Container.shared.feedService.register {
        
        let loader = EncodingMockLoader(model: Feed.stub(withID: 1)
            .setting(\.name, to: "Feed")
            .setting(\.posts, to: [
                Post.stub(withID: 1),
                Post.stub(withID: 2)
            ])
        )
        
        let cache = try! Storage<String, Feed>(
            diskConfig: DiskConfig(name: "FeedService"),
            memoryConfig: MemoryConfig(),
            transformer: TransformerFactory.forCodable(ofType: Feed.self)
        )
        
        return DefaultFeedService(loader, cache)
        
    }
    
    
    let viewModel = FeedPostListViewModel(feedID: 3)
    
    return FeedViewScreen(viewModel: viewModel, showPost: { post in
        
    })
    
}
