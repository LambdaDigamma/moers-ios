//
//  DepartureMonitorEntry.swift
//  Moers
//
//  Created by Lennart Fischer on 07.12.21.
//  Copyright © 2021 Lennart Fischer. All rights reserved.
//

import Foundation
import WidgetKit
import EFAAPI

struct DepartureMonitorEntry: TimelineEntry {
    
    var date: Date
    var name: String = ""
    var departures: [DepartureViewModel]
    
}
