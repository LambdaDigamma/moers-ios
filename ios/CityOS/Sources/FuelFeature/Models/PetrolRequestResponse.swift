//
//  PetrolRequestResponse.swift
//  MMAPI
//
//  Created by Lennart Fischer on 05.04.19.
//  Copyright © 2019 LambdaDigamma. All rights reserved.
//

import Foundation

public struct PetrolRequestResponse: Codable {
    
    public var ok: Bool
    public var license: String
    public var data: String
    public var status: String
    public var message: String?
    public var stations: [PetrolStation]?
    
    public var isValid: Bool {
        return ok
    }
    
}
