//
//  BlockYouTube.swift
//  
//
//  Created by Lennart Fischer on 24.05.22.
//

import Foundation
import ProseMirror

public struct BlockYouTubeVideo: Blockable, Equatable, Hashable {

    public static let type: BlockType = .youtubeVideo

    public var videoID: String?
    public var text: Document?

    public enum CodingKeys: String, CodingKey {
        case videoID = "video_id"
        case text = "text"
    }

    public static func == (lhs: BlockYouTubeVideo, rhs: BlockYouTubeVideo) -> Bool {
        return lhs.videoID == rhs.videoID
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(videoID)
    }

}
