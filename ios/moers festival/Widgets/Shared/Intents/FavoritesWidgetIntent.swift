//
//  FavoritesWidgetIntent.swift
//  WidgetsExtension
//
//  Created by Codex on 05.04.26.
//

import AppIntents


@available(iOSApplicationExtension 17.0, *)
struct FavoritesWidgetIntent: WidgetConfigurationIntent {

    static let title: LocalizedStringResource = "Favorite Events"
    static let description = IntentDescription("Shows your live and upcoming favorite events.")

    init() {}
}
