//
//  OpeningHours.swift
//  
//
//  Created by Lennart Fischer on 16.01.22.
//

import Foundation

public struct OpeningHourEntry: Identifiable {
    
    public let id: UUID = UUID()
    public let text: String
    public let time: String
    
    public init(text: String, time: String) {
        self.text = text
        self.time = time
    }
    
}
