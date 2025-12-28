//
//  DisplayCachableAnnotation.swift
//  moers festival
//
//  Created by Lennart Fischer on 12.05.22.
//  Copyright © 2022 Code for Niederrhein. All rights reserved.
//

import Foundation

public protocol DisplayCacheableAnnotation {
    
    static var displayCacheKey: String { get }
    
}
