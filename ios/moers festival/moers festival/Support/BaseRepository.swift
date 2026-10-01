//
//  BaseRepository.swift
//  moers festival
//
//  Created by Lennart Fischer on 12.03.23.
//  Copyright © 2023 Code for Niederrhein. All rights reserved.
//

import Foundation
import Combine

public class BaseRepository {
    
    public var cancellables = Set<AnyCancellable>()

    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}
}
