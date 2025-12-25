//
//  PostDetailScreen.swift
//  
//
//  Created by Lennart Fischer on 08.04.23.
//

import SwiftUI
import MMPages
import MediaLibraryKit

struct PostDetailScreen: View {
    
    @ObservedObject var viewModel: PostViewModel
    @EnvironmentObject var actionTransmitter: ActionTransmitter
    
    var body: some View {
        
        ZStack {
            
            viewModel.state.isLoading {
                ProgressView()
                    .progressViewStyle(.circular)
                    .padding()
            }
            
            viewModel.state.hasResource { (post: Post) in
                
                if post.extras?.type == "instagram" {
                    
                    if let href = post.externalHref, let url = URL(string: href) {
                        IsolatedWebView(url: url)
                    } else {
                        Text("404. Not found.")
                            .foregroundColor(.secondary)
                            .padding()
                    }
                    
                } else {
                    defaultPage(post: post)
                }
                
            }
            
            viewModel.state.hasError { (error: Error) in
                Text(error.localizedDescription)
                    .padding()
            }
            
        }
        .task {
            viewModel.reload()
        }
        
    }
    
    @ViewBuilder
    private func defaultPage(post: Post) -> some View {
        
        ScrollView {
            
            if viewModel.pageID != nil, let pageViewModel = viewModel.pageViewModel {
                
                viewModel.pageState.hasResource { (page: Page) in
                    
                    if let media = post.mediaCollections?.getFirstMedia(for: "insel") {
                        
                        GenericMediaView(media: media, resizingMode: .aspectFill)
                            .aspectRatio(CGSize(width: 16, height: 9), contentMode: .fill)
                            .frame(maxWidth: .infinity)
                        
                    }
                    
                }
                
                viewModel.pageState.hasError { (error: Error) in
                    Text(error.localizedDescription)
                }
                
                NativePageView(
                    viewModel: pageViewModel,
                    actionTransmitter: actionTransmitter
                )
                
            }
            
        }
        .refreshable {
            viewModel.refresh()
        }
        
    }
    
}

//struct PostDetailPage: View {
//
//    @StateObject var
//
//    init(pageID: Page.ID) {
//
//
//    }
//
//}
