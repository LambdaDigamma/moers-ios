//
//  RadioViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 23.09.21.
//  Copyright © 2021 Lennart Fischer. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import OSLog

class RadioViewController: UIViewController {
    
    private let logger: Logger = Logger(.coreUi)
    private var player: AVPlayer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupPlayer()
        self.setupRemoteTransportControls()
        self.setupNowPlaying()
        
    }
    
    private func setupPlayer() {
        
        let newURL = URL(string: "https://fms.nrwision.de/vod/_definst_/mp4:content-7/0159372270afb498017117909e440349/v.1.0.dlamber_a_13_2020.mp3.m4a/playlist.m3u8")!
        
//        let asset = AVURLAsset(url: RadioService.shared.url, options: nil)
        let asset = AVURLAsset(url: newURL, options: nil)
        let item = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: nil)
        
        self.player = AVPlayer(playerItem: item)
        
        do {
            
            try AVAudioSession.sharedInstance().setCategory(
                AVAudioSession.Category.playback
            )
            
        } catch {
            logger.error("Setting audio session categories failed: \(error.localizedDescription)")
        }
        
        self.player.play()
        
    }
    
    private func setupRemoteTransportControls() {
        
        // Get the shared MPRemoteCommandCenter
        let commandCenter = MPRemoteCommandCenter.shared()
        
        // Add handler for Play Command
        commandCenter.playCommand.addTarget { [unowned self] _ in
            if self.player.rate == 0.0 {
                self.player.play()
                return .success
            }
            return .commandFailed
        }
        
        // Add handler for Pause Command
        commandCenter.pauseCommand.addTarget { [unowned self] _ in
            if self.player.rate == 1.0 {
                self.player.pause()
                return .success
            }
            return .commandFailed
        }
    }
    
    private func setupNowPlaying() {
        // Define Now Playing Info
        var nowPlayingInfo = [String : Any]()
        nowPlayingInfo[MPMediaItemPropertyTitle] = "Radio KW"
        
        if let image = UIImage(named: "radio-kw") {
            nowPlayingInfo[MPMediaItemPropertyArtwork] =
            MPMediaItemArtwork(boundsSize: image.size) { _ in
                return image
            }
        }
        
//        nowPlayingInfo[MPMediaItemPropertyMediaType] = MPNowPlayingInfoMediaType.audio // MPMediaType.anyAudio
//        nowPlayingInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = playerItem.currentTime().seconds
//        nowPlayingInfo[MPMediaItemPropertyPlaybackDuration] = playerItem.asset.duration.seconds
//        nowPlayingInfo[MPNowPlayingInfoPropertyPlaybackRate] = player.rate
        
        MPNowPlayingInfoCenter.default().nowPlayingInfo = nowPlayingInfo
    }
    
}
