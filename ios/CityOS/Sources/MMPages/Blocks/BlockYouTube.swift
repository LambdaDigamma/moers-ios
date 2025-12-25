//
//  BlockYouTube.swift
//  
//
//  Created by Lennart Fischer on 24.05.22.
//

import Foundation
import ProseMirror

public struct BlockYouTubeVideo: Blockable {
    
    public static var type: BlockType = .youtubeVideo
    
    public var videoID: String?
    public var text: Document?
    
    public enum CodingKeys: String, CodingKey {
        case videoID = "video_id"
        case text = "text"
    }
    
}
