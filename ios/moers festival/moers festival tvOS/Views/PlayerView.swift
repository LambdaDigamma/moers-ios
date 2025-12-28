//
//  PlayerView.swift
//  moers festival tvOS
//
//  Created by Lennart Fischer on 13.04.21.
//  Copyright © 2021 Code for Niederrhein. All rights reserved.
//

import SwiftUI
import AVKit

struct PlayerView: View {
    
    @State private var player: AVPlayer?
    
    init() {
        self.player = AVPlayer(url: URL(string: "https://player.vimeo.com/external/535519606.hd.mp4?s=51b8388cc0e9d5d1ce87a132d294d2e175733c78&profile_id=175&oauth2_token_id=1482746262")!)
    }
    
    var body: some View {
        VideoPlayer(player: player)
            .onAppear {
                if let error = self.player?.error {
                    print(error)
                }
                
//                if player == nil {
//
//                }
                
//                if player?.isPlaying == false { player?.play() }
            }
            .edgesIgnoringSafeArea(.all)
    }
    
}

struct PlayerView_Previews: PreviewProvider {
    static var previews: some View {
        PlayerView()
    }
}
