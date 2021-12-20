//
//  NowPlayableStaticMetadata.swift
//  
//
//  Created by Lennart Fischer on 19.12.21.
//

import Foundation
import MediaPlayer

extension MPNowPlayingInfoMediaType: Codable {}

public struct NowPlayableStaticMetadata: Equatable, Hashable {
    
    /// Represents the `MPNowPlayingInfoPropertyAssetURL` property
    public let assetURL: URL
    
    /// Represents the `MPNowPlayingInfoPropertyMediaType` property
    public let mediaType: MPNowPlayingInfoMediaType
    
    /// Represents the `MPNowPlayingInfoPropertyIsLiveStream` property
    public let isLiveStream: Bool
    
    /// Represents the `MPMediaItemPropertyTitle` property
    public let title: String
    
    /// Represents the `MPMediaItemPropertyArtist` property
    public let artist: String?
    
    /// Represents the `MPMediaItemPropertyArtwork` property
    public let artwork: MPMediaItemArtwork?
    
    /// Represents the `MPMediaItemPropertyAlbumArtist` property
    public let albumArtist: String?
    
    /// Represents the `MPMediaItemPropertyAlbumTitle` property
    public let albumTitle: String?
    
    public init(
        assetURL: URL,
        mediaType: MPNowPlayingInfoMediaType,
        isLiveStream: Bool,
        title: String,
        artist: String? = nil,
        artwork: MPMediaItemArtwork? = nil,
        albumArtist: String? = nil,
        albumTitle: String? = nil
    ) {
        self.assetURL = assetURL
        self.mediaType = mediaType
        self.isLiveStream = isLiveStream
        self.title = title
        self.artist = artist
        self.artwork = artwork
        self.albumArtist = albumArtist
        self.albumTitle = albumTitle
    }
    
}
