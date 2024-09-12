//
//  DashboardDisplayable.swift
//  
//
//  Created by Lennart Fischer on 20.12.21.
//

import Foundation
import SwiftUI

public protocol DashboardItemConfigurable: Codable {
    
    var id: UUID { get }
    
}
