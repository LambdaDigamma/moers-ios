//
//  PostExtras.swift
//  
//
//  Created by Lennart Fischer on 01.04.23.
//

import Foundation

public struct PostExtras: Codable, Equatable, Hashable {
    
    let cta: String?
    let videoFiles: [VimeoVideoFileDescription]?
    let videoThumbnails: VimeoVideoThumbnailDescription?
    let type: String?
    
    public enum CodingKeys: String, CodingKey {
        case cta = "cta"
        case videoFiles = "video_files"
        case videoThumbnails = "video_thumbnails"
        case type = "type"
    }
    
}
