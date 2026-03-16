//
//  MediaCollectionsContainer+Hashable.swift
//  
//
//  Created by Gemini CLI on 15.03.26.
//

import Foundation
import MediaLibraryKit

extension MediaCollectionsContainer: @retroactive Hashable {
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(collections)
    }
    
}
