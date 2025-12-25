//
//  PlaybackItem.swift
//  
//
//  Created by Lennart Fischer on 19.12.21.
//

import Foundation
import AVFoundation

public struct PlaybackItem: Equatable, Hashable {
    
    public let asset: AVAsset
    public let metadata: NowPlayableStaticMetadata
    
    public init(
        asset: AVAsset,
        metadata: NowPlayableStaticMetadata
    ) {
        self.asset = asset
        self.metadata = metadata
    }
    
    public init(metadata: NowPlayableStaticMetadata) {
        let assetURL = AVURLAsset(url: metadata.assetURL)
        self.init(asset: assetURL, metadata: metadata)
    }
    
}
