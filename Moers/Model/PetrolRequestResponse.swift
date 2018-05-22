//
//  PetrolRequestResponse.swift
//  Moers
//
//  Created by Lennart Fischer on 21.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Foundation

struct PetrolRequestResponse: Codable {
    
    var ok: Bool
    var license: String
    var data: String
    var status: String
    var message: String?
    var stations: [PetrolStation]?
    
    var isValid: Bool {
        return ok
    }
    
}
