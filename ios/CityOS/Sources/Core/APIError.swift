//
//  APIError.swift
//  MMAPI
//
//  Created by Lennart Fischer on 05.04.19.
//  Copyright © 2019 LambdaDigamma. All rights reserved.
//

import Foundation

public enum APIError: Error {
    
    case noConnection
    case noData
    case noToken
    case unavailableURL
    case notAuthorized
    case unprocessableEntity(errorBag: ErrorBag?)
    case unknownResponse
    case networkError(Error)
    case requestError(Int)
    case serverError(Int)
    case decodingError(DecodingError)
    case unhandledResponse
    
}

extension APIError {
    
    static func error(from response: URLResponse?) -> APIError? {
        
        guard let http = response as? HTTPURLResponse else {
            return .unknownResponse
        }

        switch http.statusCode {
        
        case 200...299: return nil

        case 400...499: return .requestError(http.statusCode)

        case 500...599: return .serverError(http.statusCode)

        default: return .unhandledResponse
            
        }
        
    }
    
}
