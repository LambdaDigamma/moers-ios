//
//  PostViewModel.swift
//  moers festival
//
//  Created by Lennart Fischer on 22.04.21.
//  Copyright © 2021 Code for Niederrhein. All rights reserved.
//

import Foundation
import MMFeeds
import AVKit

class LegacyPostViewModel: Identifiable, ObservableObject, Hashable {
    
    let id = UUID()
    let model: Post
    
    private var _player: AVPlayerItem? = nil
    
    public var player: AVPlayerItem? {
        get {
            if let player = _player {
                return player
            } else {
                if let url = self.model.preferredVideoFile {
                    
                    let asset = AVAsset(url: url)
                    _player = AVPlayerItem(asset: asset)
                    return _player
                } else {
                    return nil
                }
            }
        }
        set {
            _player = newValue
        }
    }
    
    init(model: Post) {
        self.model = model
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: LegacyPostViewModel, rhs: LegacyPostViewModel) -> Bool {
        return lhs.id == rhs.id
    }
    
}
