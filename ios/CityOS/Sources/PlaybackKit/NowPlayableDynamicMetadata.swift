//
//  NowPlayableDynamicMetadata.swift
//  
//
//  Created by Lennart Fischer on 19.12.21.
//

import Foundation
import MediaPlayer

public struct NowPlayableDynamicMetadata: Equatable, Hashable {
    
    /// Represents the `MPNowPlayingInfoPropertyPlaybackRate` property
    public let rate: Float
    
    /// Represents the `MPNowPlayingInfoPropertyElapsedPlaybackTime` property
    public let position: Float
    
    /// Represents the `MPMediaItemPropertyPlaybackDuration` property
    public let duration: Float
    
    /// Represents the `MPNowPlayingInfoPropertyCurrentLanguageOptions` property
    public let currentLanguageOptions: [MPNowPlayingInfoLanguageOption]
    
    /// Represents the `MPNowPlayingInfoPropertyAvailableLanguageOptions` property
    public let availableLanguageOptionGroups: [MPNowPlayingInfoLanguageOptionGroup]
    
    public init(
        rate: Float,
        position: Float,
        duration: Float,
        currentLanguageOptions: [MPNowPlayingInfoLanguageOption],
        availableLanguageOptionGroups: [MPNowPlayingInfoLanguageOptionGroup]
    ) {
        self.rate = rate
        self.position = position
        self.duration = duration
        self.currentLanguageOptions = currentLanguageOptions
        self.availableLanguageOptionGroups = availableLanguageOptionGroups
    }
    
}
