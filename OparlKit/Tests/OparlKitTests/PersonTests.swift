//
//  PersonTests.swift
//  
//
//  Created by Lennart Fischer on 24.08.22.
//

import Foundation
import XCTest
@testable import OparlKit

class PersonTests: XCTestCase {
    
    func testDecode() throws {
        
        let data = """
        {
            "id": "https://oparl.example.org/person/29",
            "type": "https://schema.oparl.org/1.1/Person",
            "body": "https://oparl.example.org/body/0",
            "name": "Prof. Dr. Max Mustermann",
            "familyName": "Mustermann",
            "givenName": "Max",
            "title": [
                "Prof.",
                "Dr."
            ],
            "formOfAddress": "Ratsfrau",
            "gender": "male",
            "email": [
                "max@mustermann.de"
            ],
            "phone": [
                "+493012345678"
            ],
            "status": [
                "Bezirksbürgermeister"
            ],
            "membership": [
            {
                "id": "https://oparl.example.org/memberships/385",
                "type": "https://schema.oparl.org/1.1/Membership",
                "organization": "https://oparl.example.org/organizations/5",
                "role": "Vorsitzende",
                "votingRight": true,
                "startDate": "2013-12-03",
                "created": "2011-11-11T11:11:00+01:00",
                "modified": "2012-08-16T14:05:27+02:00"
            },
            {
                "id": "https://oparl.example.org/memberships/693",
                "type": "https://schema.oparl.org/1.1/Membership",
                "organization": "https://oparl.example.org/organizations/9",
                "role": "Sachkundige Bürgerin",
                "votingRight": false,
                "startDate": "2013-12-03",
                "endDate": "2014-07-28",
                "created": "2011-11-11T11:11:00+01:00",
                "modified": "2012-08-16T14:05:27+02:00"
            }
            ],
            "created": "2011-11-11T11:11:00+01:00",
            "modified": "2012-08-16T14:05:27+02:00"
        }
        """
        
        let decoder = OparlDecoder()
        let person = try decoder.decode(Person.self, from: data.data(using: .utf8)!)
        
        XCTAssertEqual(person.id, "https://oparl.example.org/person/29")
        XCTAssertEqual(person.type, "https://schema.oparl.org/1.1/Person")
        XCTAssertEqual(person.body, "https://oparl.example.org/body/0")
        XCTAssertEqual(person.name, "Prof. Dr. Max Mustermann")
        XCTAssertEqual(person.familyName, "Mustermann")
        XCTAssertEqual(person.givenName, "Max")
        XCTAssertEqual(person.title, ["Prof.", "Dr."])
        XCTAssertEqual(person.formOfAddress, "Ratsfrau")
        XCTAssertEqual(person.gender, "male")
        XCTAssertEqual(person.email, ["max@mustermann.de"])
        XCTAssertEqual(person.phone, ["+493012345678"])
        XCTAssertEqual(person.status, ["Bezirksbürgermeister"])
        XCTAssertEqual(person.membership?.count, 2)
        XCTAssertNotNil(person.created)
        XCTAssertNotNil(person.modified)
        
    }
    
}
