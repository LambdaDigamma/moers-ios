//
//  DeepLinkRouterSpyAction.swift
//  moers festival Tests
//
//  Created by Codex on 19.05.26.
//  Copyright © 2026 Code for Niederrhein. All rights reserved.
//

enum DeepLinkRouterSpyAction: Equatable {
    case news
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
