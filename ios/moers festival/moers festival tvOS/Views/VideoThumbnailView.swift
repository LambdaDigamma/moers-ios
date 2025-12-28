//
//  VideoThumbnailView.swift
//  moers festival tvOS
//
//  Created by Lennart Fischer on 13.04.21.
//  Copyright © 2021 Code for Niederrhein. All rights reserved.
//

import SwiftUI

struct VideoThumbnailView: View {
//    var video: Video
    
    @Environment(\.isFocused) var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Image("")
                // 1
                .resizable()
                // 2
                .renderingMode(.original)
                // 3
                .aspectRatio(contentMode: .fill)
                // 4
                .frame(width: 450, height: 255)
                // 1
                .clipped()
                // 2
                .cornerRadius(10)
                // 3
                .shadow(radius: 5)
            // 1
            VStack(alignment: .leading) {
                // 2
                Text("Test Video")
                    .foregroundColor(.primary)
                    .font(.headline)
                    .bold()
                // 3
                Text("No description provided for this video.") // video.description.isEmpty // video.description
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .frame(height: 80)
            }
        }
    }
}

struct VideoItem_Previews: PreviewProvider {
    static var previews: some View {
        VideoThumbnailView(
//            video: Video(
//                title: "Introduction to ARKit",
//                description: "Learn about ARKit in this amazing tutorial!",
//                thumbnailName: "arkit"
//            )
        )
    }
}
