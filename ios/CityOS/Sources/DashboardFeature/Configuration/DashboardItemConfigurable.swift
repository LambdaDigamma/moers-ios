//
//  DashboardDisplayable.swift
//  
//
//  Created by Lennart Fischer on 20.12.21.
//

import Foundation
import SwiftUI

nonisolated public protocol DashboardItemConfigurable: Codable, Sendable {
    
    var id: UUID { get }
    
}
