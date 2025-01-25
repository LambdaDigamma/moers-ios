//
//  BlockLinkList.swift
//  
//
//  Created by Lennart Fischer on 24.05.22.
//

import Foundation
import ProseMirror

public struct BlockLinkList: Blockable {
    
    public static var type: BlockType = .youtubeVideo
    
    public var links: [LinkEntry] = []
    
    public enum CodingKeys: String, CodingKey {
        case links = "links"
    }
    
    public struct LinkEntry: Codable, Identifiable {
        
        public let id: UUID = UUID()
        
        public var text: String
        public var href: String
        public var icon: LinkIcon
        public var color: LinkColor
        
        public enum CodingKeys: String, CodingKey {
            case text
            case href
            case icon
            case color
        }
        
    }
        
    public enum LinkIcon: String, Codable {
        case link = "link"
        case twitter = "twitter"
        case instagram = "instagram"
        case facebook = "facebook"
        case youtube = "youtube"
        case spotify = "spotify"
        case appleMusic = "apple-music"
        case bandcamp = "bandcamp"
        case soundCloud = "soundcloud"
    }
    
    public enum LinkColor: String, Codable {
        case red = "red"
        case yellow = "yellow"
        case pink = "pink"
        case green = "green"
        case orange = "orange"
        case blue = "blue"
        case black = "black"
    }
    
}
