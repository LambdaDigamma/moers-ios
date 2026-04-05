//
//  FavoritesWidget.swift
//  WidgetsExtension
//
//  Created by Codex on 05.04.26.
//

import SwiftUI
import WidgetKit
import AppIntents


struct FavoritesWidget: Widget {

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: WidgetKind.favorites.rawValue,
            intent: FavoritesWidgetIntent.self,
            provider: FavoritesWidgetProvider()
        ) { entry in
            FestivalWidgetView(entry: entry)
        }
        .configurationDisplayName("Favorites")
        .description("Your live and upcoming favorite moers festival events.")
        .supportedFamilies([
            .systemSmall,
            .systemMedium,
            .systemLarge,
//            .accessoryInline,
//            .accessoryRectangular,
//            .accessoryCircular
        ])
    }
 
}

#Preview("Favorites / Small / Baseline", as: .systemSmall) {
    FavoritesWidget()
} timeline: {
    FestivalWidgetEntry.previewFavorites
}

#Preview("Favorites / Medium / Dense", as: .systemMedium) {
    FavoritesWidget()
} timeline: {
    FestivalWidgetEntry.previewFavoritesChaos
    FestivalWidgetEntry.previewFavorites
}

#Preview("Favorites / Large / Empty", as: .systemLarge) {
    FavoritesWidget()
} timeline: {
    FestivalWidgetEntry.previewFavoritesChaos
    FestivalWidgetEntry.previewFavoritesEmpty
}

#Preview("Favorites / Accessory Rectangular", as: .accessoryRectangular) {
    FavoritesWidget()
} timeline: {
    FestivalWidgetEntry.previewFavoritesChaos
}

#Preview("Favorites / Accessory Inline", as: .accessoryInline) {
    FavoritesWidget()
} timeline: {
    FestivalWidgetEntry.previewFavorites
}

#Preview("Favorites / Accessory Circular", as: .accessoryCircular) {
    FavoritesWidget()
} timeline: {
    FestivalWidgetEntry.previewFavorites
}
