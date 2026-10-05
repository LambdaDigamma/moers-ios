//
//  FavoritesWidgetIntent.swift
//  WidgetsExtension
//
//  Created by Codex on 05.04.26.
//

import AppIntents


struct FavoritesWidgetIntent: WidgetConfigurationIntent {

    static let title: LocalizedStringResource = "Favorite Events"
    static let description = IntentDescription("Shows your live and upcoming favorite events.")

    init() {}
}
