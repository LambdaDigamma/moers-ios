//
//  PageDisplayConfiguration.swift
//  
//
//  Created by Lennart Fischer on 12.03.21.
//

import Foundation

public struct PageDisplayConfiguration {
    
    public var showShare: Bool = true
    public var showLike: Bool = false
    
    public var likeState: (() -> Bool)?
    public var toggleLike: (() -> Bool)?
    
    public init(showShare: Bool = true, showLike: Bool = false) {
        self.showShare = showShare
        self.showLike = showLike
    }
    
}
