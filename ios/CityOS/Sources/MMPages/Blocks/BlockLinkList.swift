//
//  BlockLinkList.swift
//  
//
//  Created by Lennart Fischer on 24.05.22.
//

import Foundation
import ProseMirror

nonisolated public struct BlockLinkList: Blockable, Equatable {
    
    public static let type: BlockType = .youtubeVideo
    
    public var links: [LinkEntry] = []
    
    public enum CodingKeys: String, CodingKey {
        case links = "links"
    }
    
    nonisolated public struct LinkEntry: Codable, Identifiable, Equatable, Hashable, Sendable {
        
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
        
    nonisolated public enum LinkIcon: String, Codable, Equatable, Sendable {
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
    
    nonisolated public enum LinkColor: String, Codable, Equatable, Sendable {
        case red = "red"
        case yellow = "yellow"
        case pink = "pink"
        case green = "green"
        case orange = "orange"
        case blue = "blue"
        case black = "black"
    }
    
}
