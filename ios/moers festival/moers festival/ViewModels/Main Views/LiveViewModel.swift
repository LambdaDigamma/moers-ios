//
//  LiveViewModel.swift
//  moers festival
//
//  Created by Lennart Fischer on 02.05.20.
//  Copyright © 2020 CodeForNiederrhein. All rights reserved.
//

import Foundation
import Combine

class LiveViewModel {
    
    private let cancellables = Set<AnyCancellable>()
    
    init() {
        
        
        
    }

    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}
}
