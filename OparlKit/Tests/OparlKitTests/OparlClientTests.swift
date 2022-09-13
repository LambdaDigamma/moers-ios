//
//  OparlClientTests.swift
//  
//
//  Created by Lennart Fischer on 24.08.22.
//

import Foundation
import XCTest
import OparlKit

class OparlClientTests: XCTestCase {
    
    public func testInit() async throws {
        
        let client = try OparlClient(
            systemURL: "https://www.sitzungsdienst-lichtenberg.de/oi/oparl/1.0/system.asp"
        )
        
        let bodies = try await client.loadBodies()
        
        XCTAssertFalse(bodies.isEmpty)
        
    }
    
    public func testLoadPersons() async throws {
        
        let client = try OparlClient(
            systemURL: "https://www.sitzungsdienst-lichtenberg.de/oi/oparl/1.0/system.asp"
        )
        
        let persons = try await client.loadPersons(
            personsURL: "https://www.sitzungsdienst-lichtenberg.de/oi/oparl/1.0/persons.asp?body=1"
        )
        
        XCTAssertFalse(persons.isEmpty)
        
    }
    
}
