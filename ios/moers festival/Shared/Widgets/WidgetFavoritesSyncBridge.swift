//
//  WidgetFavoritesSyncBridge.swift
//  moers festival
//
//  Created by Codex on 05.04.26.
//

import Foundation
import Combine
import Factory
import MMEvents
import WidgetKit

enum FestivalWidgetSharedConstants {

    static let appGroupID = "group.de.okfn.niederrhein.moers-festival"
    static let favoriteEventIDsKey = "widget.favorite-event-ids"
    static let upcomingWidgetKind = "de.okfn.niederrhein.moers-festival.widget.upcoming"
    static let favoritesWidgetKind = "de.okfn.niederrhein.moers-festival.widget.favorites"

}

extension Container {

    var widgetFavoritesSyncBridge: Factory<WidgetFavoritesSyncBridge> {
        self {
            MainActor.assumeIsolated {
                WidgetFavoritesSyncBridge(
                    favoriteEventsStore: self.favoriteEventsStore()
                )
            }
        }
        .singleton
    }

}

@MainActor
final class WidgetFavoritesSyncBridge {

    private let favoriteEventsStore: FavoriteEventsStore?
    private let sharedDefaults = UserDefaults(suiteName: FestivalWidgetSharedConstants.appGroupID)
    private var cancellables = Set<AnyCancellable>()
    private var hasStarted = false

    init(favoriteEventsStore: FavoriteEventsStore?) {
        self.favoriteEventsStore = favoriteEventsStore
    }

    func start() {
        guard !hasStarted, let favoriteEventsStore else {
            return
        }

        hasStarted = true

        favoriteEventsStore.observeFavoriteEvents()
            .map { favoriteEvents in
                favoriteEvents
                    .compactMap(\.event.id)
                    .map(Int.init)
                    .sorted()
            }
            .replaceError(with: [])
            .sink { [weak self] favoriteIDs in
                self?.sharedDefaults?.set(favoriteIDs, forKey: FestivalWidgetSharedConstants.favoriteEventIDsKey)
                WidgetCenter.shared.reloadTimelines(ofKind: FestivalWidgetSharedConstants.upcomingWidgetKind)
                WidgetCenter.shared.reloadTimelines(ofKind: FestivalWidgetSharedConstants.favoritesWidgetKind)
            }
            .store(in: &cancellables)
    }

}
