//
//  DataResponse.swift
//  
//
//  Created by Lennart Fischer on 16.01.22.
//

import Foundation
import ModernNetworking

nonisolated public struct DataResponse<ResponseData: Codable>: Codable {
    
    public var data: ResponseData
    
}

extension DataResponse: Sendable where ResponseData: Sendable {}

nonisolated extension DataResponse: Model {
    
    
    
}
