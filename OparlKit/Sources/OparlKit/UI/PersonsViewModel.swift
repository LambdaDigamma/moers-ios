//
//  PersonsViewModel.swift
//  
//
//  Created by Lennart Fischer on 24.08.22.
//

import Foundation
import OparlKit

public class PersonsViewModel: ObservableObject {
    
    public let client: OparlClient
    
    public var currentBody: Body?
    
    @Published var persons: [Person] = []
    
    public init() {
        do {
            self.client = try OparlClient(
                systemURL: "https://www.sitzungsdienst-lichtenberg.de/oi/oparl/1.0/system.asp"
            )
        } catch {
            fatalError("Could not create oparl client.")
        }
    }
    
    public func initIfNeeded() async throws {
        if currentBody == nil {
            self.currentBody = try await client.loadBodies().first
        }
    }
    
    public func loadPersons() async throws {
        
        guard let personsURL = currentBody?.person else { return }
        
        let newPersons = try await client.loadPersons(personsURL: personsURL)
        
        DispatchQueue.main.async {
            self.persons = newPersons
        }
        
    }
    
}
