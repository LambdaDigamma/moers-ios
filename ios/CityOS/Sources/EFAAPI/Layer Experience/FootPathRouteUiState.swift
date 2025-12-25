//
//  FootPathRouteUiState.swift
//  
//
//  Created by Lennart Fischer on 18.12.22.
//

import Foundation

public struct FootPathRouteUiState: Codable, Equatable, Hashable {
    
    public let text: String
    
    public init(text: String) {
        self.text = text
    }
    
}
