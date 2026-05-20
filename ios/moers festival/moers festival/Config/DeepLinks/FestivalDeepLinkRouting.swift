//
//  FestivalDeepLinkRouting.swift
//  moers festival
//
//  Created by Codex on 19.05.26.
//  Copyright © 2026 Code for Niederrhein. All rights reserved.
//

import Foundation

protocol FestivalDeepLinkRouting: AnyObject {
    func openNews(animated: Bool)
    func openPostDetail(postID: Int, animated: Bool)
    func openEvents(animated: Bool)
    func openEventDetail(eventID: Int, animated: Bool)
    func openUserSchedule(animated: Bool)
    func openMap(animated: Bool)
    func openVenueDetail(venueID: Int, animated: Bool)
    func openDownloadEvents(animated: Bool)
    func openInfo(animated: Bool)
    func openLegal(animated: Bool)
}
