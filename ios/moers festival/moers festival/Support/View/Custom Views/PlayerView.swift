//
//  PlayerView.swift
//  moers festival
//
//  Created by Lennart Fischer on 04.05.20.
//  Copyright © 2020 CodeForNiederrhein. All rights reserved.
//

import UIKit
import AVKit

class PlayerView: UIView {
    
    var playerLayer: AVPlayerLayer?
    var player: AVPlayer?
    var isLoop: Bool = false
    
    init() {
        super.init(frame: .zero)
        player = AVPlayer()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(url: String) {
        if let videoURL = URL(string: url) {
            player = AVPlayer(url: videoURL)
            playerLayer = AVPlayerLayer(player: player)
            playerLayer?.frame = bounds
            playerLayer?.videoGravity = AVLayerVideoGravity.resize
            if let playerLayer = self.playerLayer {
                layer.addSublayer(playerLayer)
            }
            NotificationCenter.default.addObserver(self,
                                                   selector: #selector(reachTheEndOfTheVideo(_:)),
                                                   name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                   object: self.player?.currentItem)
        }
    }
    
    func configure(playerItem: AVPlayerItem) {
        
        self.playerLayer?.removeFromSuperlayer()
        self.playerLayer = nil
        playerItem.outputs.forEach { playerItem.remove($0) }
        
        print(playerItem.asset)
        
//        player = AVPlayer(playerItem: playerItem)
        player?.replaceCurrentItem(with: playerItem)
        
        playerLayer = AVPlayerLayer(player: player)
//        playerLayer?.player.
        playerLayer?.frame = bounds
        playerLayer?.videoGravity = AVLayerVideoGravity.resize
        if let playerLayer = self.playerLayer {
            layer.addSublayer(playerLayer)
        }
        
        player?.play()
        
//        NotificationCenter.default.addObserver(self,
//                                               selector: #selector(reachTheEndOfTheVideo(_:)),
//                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
//                                               object: self.player?.currentItem)
    }
    
    func play() {
        if player?.timeControlStatus != AVPlayer.TimeControlStatus.playing {
            player?.play()
        }
    }
    
    func pause() {
        player?.pause()
    }
    
    func stop() {
        player?.pause()
        player?.seek(to: CMTime.zero)
    }
    
    @objc func reachTheEndOfTheVideo(_ notification: Notification) {
        if isLoop {
            player?.pause()
            player?.seek(to: CMTime.zero)
            player?.play()
        }
    }
    
}
