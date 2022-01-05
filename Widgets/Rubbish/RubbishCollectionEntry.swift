//
//  RubbishCollectionEntry.swift
//  WidgetsExtension
//
//  Created by Lennart Fischer on 21.12.21.
//  Copyright © 2021 Lennart Fischer. All rights reserved.
//

import Foundation
import WidgetKit
import RubbishFeature

public struct RubbishCollectionEntry: TimelineEntry {
    
    public var date: Date
    public var streetName: String = ""
    public var rubbishPickupItems: [RubbishPickupItem]
    
    public init(
        date: Date,
        streetName: String = "",
        rubbishPickupItems: [RubbishPickupItem]
    ) {
        self.date = date
        self.streetName = streetName
        self.rubbishPickupItems = rubbishPickupItems
    }
    
}
