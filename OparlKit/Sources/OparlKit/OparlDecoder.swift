//
//  OparlDecoder.swift
//  
//
//  Created by Lennart Fischer on 24.08.22.
//

import Foundation

public class OparlDecoder: JSONDecoder {
    
    public override init() {
        super.init()
        
        self.dateDecodingStrategy = .iso8601
        
    }
    
}
