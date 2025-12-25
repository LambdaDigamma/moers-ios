//
//  BigNewsFeedView.swift
//
//
//  Created by Lennart Fischer on 01.01.21.
//

import SwiftUI
import MediaLibraryKit
import NukeUI

public struct BigNewsFeedView: View {
    
    private var post: Post
    private var showPost: (_ post: Post) -> Void
    
    public init(post: Post, showPost: @escaping (_ post: Post) -> Void) {
        
        self.post = post
        self.showPost = showPost
        
    }
    
    public var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            if let videoThumbnail = post.extras?.videoThumbnails?.thumbnails.last {
                
                Rectangle()
                    .fill(Color.clear)
                    .frame(maxWidth: .infinity)
                    .aspectRatio(CGSize(width: 16, height: 9), contentMode: .fit)
                    .background(ZStack {
                        
                        LazyImage(url: videoThumbnail.link)
                        
                    })
                
            } else if let media = post.mediaCollections?.getFirstMedia(for: "default") {
                
                GenericMediaView(media: media, resizingMode: .aspectFill)
                    .aspectRatio(post.mediaAspectRatio(), contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .onTapGesture {
                        print(post)
                        showPost(post)
                    }
                
            }
            
            VStack(alignment: .leading, spacing: 4) {
                
                if post.extras?.type != "instagram" {
                    
                    Text(post.title)
                        .font(.headline)
                        .multilineTextAlignment(.leading)
                        .foregroundColor(Color.primary)
                    
                }
                
                if post.summary != "" {
                    Text(post.summary)
                        .font(.footnote)
                        .multilineTextAlignment(.leading)
                        .lineLimit(3)
                        .foregroundColor(Color.secondary)
                }
                
                
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .onTapGesture {
                showPost(post)
            }
            
        }
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .frame(alignment: .leading)

    }
    
}

struct BigNewsFeedView_Previews: PreviewProvider {
    static var previews: some View {
        BigNewsFeedView(
            post: Post.stub(withID: 1),
            showPost: { post in
            
        })
            .padding()
    }
}
