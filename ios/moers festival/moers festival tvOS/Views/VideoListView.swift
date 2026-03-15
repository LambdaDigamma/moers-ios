//
//  VideoListView.swift
//  moers festival tvOS
//
//  Created by Lennart Fischer on 13.04.21.
//  Copyright © 2021 Code for Niederrhein. All rights reserved.
//

import SwiftUI

struct VideoListView: View {
    
    let test = false
    
    var body: some View {
        Group {
            ScrollView(.vertical, showsIndicators: false) {
                if test { // categoryProvider.categories.isEmpty
                    VStack {
                        Text("fdasjdfa")
                            .font(.title2)
                            .bold()
                            .foregroundColor(Color.primary)
                        Text("Ffdasfasd")
                            .font(.title3)
                            .foregroundColor(Color.secondary)
                    }.padding()
                } else {
                    LazyVStack(alignment: .leading) {
                        
                        CategoryRow()
                        
//                        ForEach(categoryProvider.categories) { category in
//
//                        }
//                        .animation(.default)
                    }
                }
            }
        }
        .navigationTitle("Videos")
        .onAppear {
//            categoryProvider.refresh()
        }
    }
}

struct CategoryRow: View {
//    var category: Category
    @State var showOnlyFavorites = false
    @State var customTitle: String?
    
    var body: some View {
        Text("asdfsdf") // customTitle ?? category.title
            .font(.headline)
            .bold()
        
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(alignment: .top) {
//                ForEach(showOnlyFavorites ? category.favoriteVideos : category.videos) { video in
                    // VideoDetailView(category: category, video: video)
                    NavigationLink(destination: Text("ffasdf")) {
                        VideoThumbnailView()
                            .frame(maxWidth: 460)
                            .cornerRadius(10)
                            .padding()
                    }
                    .buttonStyle(PlainNavigationLinkButtonStyle())
//                }
            }
        }.padding()
    }
}


struct VideoListView_Previews: PreviewProvider {
    static var previews: some View {
        VideoListView()
    }
}
