//
//  FestivalWidgetContent.swift
//  moers festival
//
//  Created by Lennart Fischer on 05.04.26.
//  Copyright © 2026 Lennart Fischer. All rights reserved.
//


import Foundation
import SwiftUI
import WidgetKit

struct FestivalWidgetContent: Sendable {

    let liveEvents: [FestivalWidgetDisplayEvent]
    let upcomingEvents: [FestivalWidgetDisplayEvent]
    let nextRefreshDate: Date

}