//
//  VimeoVideoFileDescription.swift
//  
//
//  Created by Lennart Fischer on 01.04.23.
//

import Foundation

public struct VimeoVideoFileDescription: Codable, Equatable, Hashable {
    
    public var fps: Double?
    public var md5: String?
    public var link: URL?
    public var size: UInt64?
    public var type: String?
    public var width: Int?
    public var height: Int?
    public var quality: String?
    public var sizeShort: String?
    public var publicName: String?
    
    public enum CodingKeys: String, CodingKey {
        case fps = "fps"
        case md5 = "md5"
        case link = "link"
        case size = "size"
        case type = "type"
        case width = "width"
        case height = "height"
        case quality = "quality"
        case sizeShort = "size_short"
        case publicName = "public_name"
    }
    
}

public struct VimeoVideoThumbnailDescription: Codable, Equatable, Hashable {
    
    public var uri: String?
    public var type: String?
    public var thumbnails: [Thumbnail]
    
    public init(uri: String? = nil, type: String? = nil, thumbnails: [Thumbnail] = []) {
        self.uri = uri
        self.type = type
        self.thumbnails = thumbnails
    }
    
    public enum CodingKeys: String, CodingKey {
        case uri = "uri"
        case type = "type"
        case thumbnails = "sizes"
    }
    
    public struct Thumbnail: Codable, Equatable, Hashable {
        public var link: URL?
        public var width: Int?
        public var height: Int?
        public var linkWithPlayButton: URL?
        
        public enum CodingKeys: String, CodingKey {
            case link = "link"
            case width = "width"
            case height = "height"
            case linkWithPlayButton = "link_with_play_button"
        }
    }
    
}
