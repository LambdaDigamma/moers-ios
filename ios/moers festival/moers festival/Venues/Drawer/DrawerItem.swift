//
//  DrawerItem.swift
//  moers festival
//
//  Created by Lennart Fischer on 15.05.24.
//  Copyright © 2024 Code for Niederrhein. All rights reserved.
//

import Foundation

nonisolated public enum DrawerFestivalMapSection: Hashable, Sendable {
    case main
    case booths
}

nonisolated enum DrawerItem: Hashable, Sendable {

    case venue(FestivalPlaceRowUi)

    case booth(DorfFeature)

}
