//
//  Extensions.swift
//  moers festival tvOS
//
//  Created by Lennart Fischer on 27.05.20.
//  Copyright © 2020 CodeForNiederrhein. All rights reserved.
//

import Foundation
import AVFoundation

extension String {
    
}

extension AVPlayer {
    var isPlaying: Bool {
        return self.rate != 0.0 && self.error == nil
    }
}
