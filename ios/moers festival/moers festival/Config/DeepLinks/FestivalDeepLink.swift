//
//  FestivalDeepLink.swift
//  moers festival
//
//  Created by Codex on 19.05.26.
//  Copyright © 2026 Code for Niederrhein. All rights reserved.
//

import Foundation

enum FestivalDeepLink: Equatable {
    case posts
    case postDetail(postID: Int)
    case events
    case eventDetail(eventID: Int)
    case favorites
    case map
    case venueDetail(venueID: Int)
    case downloadEvents
    case info
    case legal
}
