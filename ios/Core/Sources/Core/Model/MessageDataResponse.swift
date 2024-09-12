//
//  MessageDataResponse.swift
//  
//
//  Created by Lennart Fischer on 23.09.21.
//

import Foundation

public struct MessageDataResponse<ResponseData: Codable>: Codable {
    public var message: String
    public var data: ResponseData
}
