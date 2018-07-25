//
//  PetrolDetailResponse.swift
//  Moers
//
//  Created by Lennart Fischer on 22.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Foundation

struct PetrolDetailResponse: Codable {
    
    var ok: Bool
    var license: String
    var data: String
    var status: String
    var station: PetrolStation?
    
    var isValid: Bool {
        return ok
    }
    
}
