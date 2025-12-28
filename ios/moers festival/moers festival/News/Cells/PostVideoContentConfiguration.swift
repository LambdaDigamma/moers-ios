//
//  PostVideoContentConfiguration.swift
//  moers festival
//
//  Created by Lennart Fischer on 22.04.21.
//  Copyright © 2021 Code for Niederrhein. All rights reserved.
//

import UIKit
import MMFeeds
import AVKit

struct PostVideoContentConfiguration: UIContentConfiguration, Hashable {
    
    var name: String
    var description: String
    var video: VimeoVideoThumbnailDescription
    var playerItem: AVPlayerItem?
    
    func makeContentView() -> UIView & UIContentView {
        return PostVideoContentView(configuration: self)
    }
    
    func updated(for state: UIConfigurationState) -> Self {
        
        guard state is UICellConfigurationState else {
            return self
        }
        
        let updatedConfiguration = self
        
        return updatedConfiguration
        
    }
    
}
