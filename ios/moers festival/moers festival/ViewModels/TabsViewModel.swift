//
//  TabsViewModel.swift
//  moers festival
//
//  Created by Lennart Fischer on 13.12.20.
//  Copyright © 2020 CodeForNiederrhein. All rights reserved.
//

import UIKit

enum TabsViewModel: String, CaseIterable {
    
    case news = "news"
    case live = "live"
    case schedule = "schedule"
    case info = "info"
    
    var icon: UIImage? {
        switch self {
            case .news: return UIImage(systemName: "newspaper.fill")
            case .live: return UIImage(systemName: "play.circle.fill")
            case .schedule: return UIImage(systemName: "calendar")
            case .info: return UIImage(systemName: "info.circle.fill")
        }
    }
    
    var title: String {
        switch self {
            case .news: return String.localized("NewsTabItem")
            case .live: return "Live"
            case .schedule: return String.localized("EventsTabItem")
            case .info: return String.localized("InfoTabItem")
        }
    }
    
    
    
}
