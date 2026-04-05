//
//  FestivalWidgetDisplayEvent.swift
//  moers festival
//
//  Created by Lennart Fischer on 05.04.26.
//  Copyright © 2026 Lennart Fischer. All rights reserved.
//


import Foundation
import SwiftUI
import WidgetKit

struct FestivalWidgetDisplayEvent: Identifiable, Hashable, Sendable {

    let event: FestivalWidgetEvent
    let status: FestivalWidgetStatus

    var id: Int { event.id }

}
