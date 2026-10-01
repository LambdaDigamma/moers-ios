//
//  DrawerViewModel.swift
//  moers festival
//
//  Created by Lennart Fischer on 01.05.19.
//  Copyright © 2019 CodeForNiederrhein. All rights reserved.
//

import Foundation
import Core

class DrawerViewModel: ObservableObject {
    
    @Published public var trackers: [Tracker] = []
    
    init(trackers: [Tracker] = []) {
        self.trackers.insert(contentsOf: trackers, at: 0)
    }

    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}
}
