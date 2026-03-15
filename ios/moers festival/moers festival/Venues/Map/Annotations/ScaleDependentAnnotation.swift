//
//  ScaleDependentAnnotation.swift
//  moers festival
//
//  Created by Lennart Fischer on 12.05.22.
//  Copyright © 2022 Code for Niederrhein. All rights reserved.
//

import Foundation

public protocol ScaleDependentAnnotation {
    
    static var mapScaleThreshold: Double { get }
    
}
