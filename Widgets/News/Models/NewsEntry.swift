//
//  NewsEntry.swift
//  
//
//  Created by Lennart Fischer on 10.06.21.
//

import Foundation
import WidgetKit

public struct NewsEntry: TimelineEntry {
    
    public let viewModels: [NewsViewModel]
    public let date: Date
    
    public init(viewModels: [NewsViewModel] = [], date: Date = Date()) {
        self.viewModels = viewModels
        self.date = date
    }
    
}
