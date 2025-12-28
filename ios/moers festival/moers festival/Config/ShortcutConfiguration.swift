//
//  ShortcutConfiguration.swift
//  moers festival
//
//  Created by Lennart Fischer on 03.01.21.
//  Copyright © 2021 CodeForNiederrhein. All rights reserved.
//

import UIKit
import AppScaffold

enum AppShortcuts {
    
    static let news = "de.okfn.niederrhein.moers-festival.news"
    static let favorites = "de.okfn.niederrhein.moers-festival.favorites"
    static let events = "de.okfn.niederrhein.moers-festival.events"
    
}

class ShortcutConfiguration: BootstrappingProcedureStep {
    
    func execute(with application: UIApplication) {
        
        let iconFavorites = UIApplicationShortcutIcon(type: .favorite)
        let itemFavorites = UIApplicationShortcutItem(
            type: AppShortcuts.favorites,
            localizedTitle: String.localized("ShortcutFavourites"),
            localizedSubtitle: nil,
            icon: iconFavorites,
            userInfo: nil
        )
        
        
        let iconEvents = UIApplicationShortcutIcon(type: .date)
        let itemEvents = UIApplicationShortcutItem(
            type: AppShortcuts.events,
            localizedTitle: String.localized("ShortcutEvents"),
            localizedSubtitle: nil,
            icon: iconEvents,
            userInfo: nil
        )
        
        let iconNews = UIApplicationShortcutIcon(type: .time)
        let itemNews = UIApplicationShortcutItem(
            type: AppShortcuts.news,
            localizedTitle: String.localized("ShortcutNews"),
            localizedSubtitle: nil,
            icon: iconNews,
            userInfo: nil
        )
        
        application.shortcutItems = [itemFavorites, itemEvents, itemNews]
        
    }
    
}
