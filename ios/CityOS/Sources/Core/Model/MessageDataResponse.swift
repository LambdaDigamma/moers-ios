//
//  MessageDataResponse.swift
//  
//
//  Created by Lennart Fischer on 23.09.21.
//

import Foundation

nonisolated public struct MessageDataResponse<ResponseData: Codable>: Codable {
    public var message: String
    public var data: ResponseData
}

extension MessageDataResponse: Sendable where ResponseData: Sendable {}
