//
//  InstagramPostView.swift
//  
//
//  Created by Lennart Fischer on 08.05.23.
//

import SwiftUI
import MediaLibraryKit
import NukeUI

public struct InstagramPostView: View {
    
    private var post: Post
    private var showPost: (_ post: Post) -> Void
    
    public init(post: Post, showPost: @escaping (_ post: Post) -> Void) {
        
        self.post = post
        self.showPost = showPost
        
    }
    
    public var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            if let media = post.mediaCollections?.getFirstMedia(for: "default") {
                
                GenericMediaView(media: media, resizingMode: .aspectFill)
                    .aspectRatio(post.mediaAspectRatio(), contentMode: .fit)
                    .frame(maxWidth: .infinity)
                    .onTapGesture {
                        print(post)
                        showPost(post)
                    }
                
            }
            
            if post.summary != "" {
                
                VStack(alignment: .leading, spacing: 4) {
                    
                    Text(post.summary)
                        .font(.footnote)
                        .multilineTextAlignment(.leading)
                        .lineLimit(5)
                        .foregroundColor(Color.secondary)
                    
                }
                .padding()
                .frame(maxWidth: .infinity, alignment: .leading)
                
            }
            
        }
        .background(Color(UIColor.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onTapGesture {
            showPost(post)
        }
        .frame(alignment: .leading)
        
    }
    
}

struct InstagramPostView_Previews: PreviewProvider {
    static var previews: some View {
        InstagramPostView(
            post: Post.stub(withID: 1),
            showPost: { post in
                
            })
        .padding()
    }
}
