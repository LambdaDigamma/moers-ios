//
//  OparlClient.swift
//  
//
//  Created by Lennart Fischer on 24.08.22.
//

import Foundation

enum OparlError: LocalizedError {
    case invalidURL
}

public struct OparlPaginatedResponse<Item: Codable & Equatable>: Codable, Equatable {
    
    public let data: [Item]
    
}

public class OparlClient {
    
    private let systemURL: URL
    private let session: URLSession = .shared
    private let decoder: OparlDecoder = .init()
    
    public init(systemURL: SystemURL) throws {
        
        guard let system = URL(string: systemURL) else {
            throw OparlError.invalidURL
        }
        
        self.systemURL = system
        
    }
    
    public func loadBodies() async throws -> [Body] {
        
        let systemRequest = URLRequest(url: systemURL)
        let (systemData, _) = try await session.data(for: systemRequest)
        let system = try decoder.decode(System.self, from: systemData)
        
        guard let bodiesURL = URL(string: system.body) else {
            throw OparlError.invalidURL
        }
        
        let bodiesRequest = URLRequest(url: bodiesURL)
        let (bodiesData, _) = try await session.data(for: bodiesRequest)
        let bodies = try decoder.decode(OparlPaginatedResponse<Body>.self, from: bodiesData)
        
        return bodies.data
        
    }
    
    public func loadPersons(personsURL: PersonURL) async throws -> [Person] {
        
        guard let personsURL = URL(string: personsURL) else {
            throw OparlError.invalidURL
        }
        
        let request = URLRequest(url: personsURL)
        let (data, _) = try await session.data(for: request)
        let decodedResponse = try decoder.decode(OparlPaginatedResponse<Person>.self, from: data)
        
        return decodedResponse.data
        
    }
    
}
