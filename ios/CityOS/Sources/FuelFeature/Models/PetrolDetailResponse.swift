//
//  PetrolDetailResponse.swift
//  MMAPI
//
//  Created by Lennart Fischer on 05.04.19.
//  Copyright © 2019 LambdaDigamma. All rights reserved.
//

import Foundation

nonisolated public struct PetrolDetailResponse: Codable {
    
    public var ok: Bool
    public var license: String
    public var data: String
    public var status: String
    public var station: PetrolStation?
    
    public var isValid: Bool {
        return ok
    }
    
}
