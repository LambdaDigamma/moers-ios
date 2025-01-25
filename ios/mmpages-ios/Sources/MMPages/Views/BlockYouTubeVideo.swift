//
//  BlockYouTubeVideo.swift
//  moers festival
//
//  Created by Lennart Fischer on 24.05.22.
//  Copyright © 2022 Code for Niederrhein. All rights reserved.
//

import SwiftUI
import YouTubePlayerKit

public struct BlockYouTubeVideoView: View {
    
    @StateObject var youTubePlayer: YouTubePlayer = .init()
    
    private let wrapper: PageBlock
    private let block: BlockYouTubeVideo
    
    public init(block: PageBlock) {
        self.wrapper = block
        self.block = block.data.base as! BlockYouTubeVideo
        
        if let videoID = self.block.videoID {
            self._youTubePlayer = .init(wrappedValue: YouTubePlayer(stringLiteral: "https://youtube.com/watch?v=\(videoID)"))
        }
    }
    
    public var body: some View {
        
        ZStack {
            
            Rectangle()
                .fill(Color(UIColor.secondarySystemBackground))
            
            YouTubePlayerView(self.youTubePlayer) { state in
                switch state {
                    case .idle:
                        ProgressView()
                    case .ready:
                        EmptyView()
                    case .error(_):
                        Text(verbatim: "YouTube player couldn't be loaded")
                }
            }
            
        }
        .aspectRatio(CGSize(width: 16, height: 9), contentMode: .fit)
        .cornerRadius(4)
        
    }
    
}

//struct BlockYouTubeVideo_Previews: PreviewProvider {
//    static var previews: some View {
//        BlockYouTubeVideoView()
//            .preferredColorScheme(.dark)
//            .padding()
//    }
//}
