//
//  NavigationProvider.swift
//  
//
//  Created by Lennart Fischer on 01.04.22.
//

import Foundation

public protocol NavigationProvider {
    
    func startNavigation(to point: Point, withName name: String)
    
}
