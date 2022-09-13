//
//  SystemTests.swift
//  
//
//  Created by Lennart Fischer on 24.08.22.
//

import Foundation
import XCTest
@testable import OparlKit

class SystemTests: XCTestCase {
    
    func testDecode() throws {
        
        let data = """
        {
            "id": "https://oparl.example.org/",
            "type": "https://schema.oparl.org/1.1/System",
            "oparlVersion": "https://schema.oparl.org/1.1/",
            "body": "https://oparl.example.org/bodies",
            "name": "Beispiel-System",
            "contactEmail": "info@example.org",
            "contactName": "Allgemeiner OParl Kontakt",
            "website": "http://www.example.org/",
            "vendor": "http://example-software.com/",
            "product": "http://example-software.com/oparl-server/",
            "otherOparlVersions": [
                "https://oparl2.example.org/"
            ],
            "created": "2011-11-11T11:11:00+01:00",
            "modified": "2012-11-11T11:11:00+01:00"
        }
        """
        
        let decoder = OparlDecoder()
        let system = try decoder.decode(System.self, from: data.data(using: .utf8)!)
        
        XCTAssertEqual(system.id, "https://oparl.example.org/")
        XCTAssertEqual(system.type, "https://schema.oparl.org/1.1/System")
        XCTAssertEqual(system.oparlVersion, "https://schema.oparl.org/1.1/")
        XCTAssertEqual(system.body, "https://oparl.example.org/bodies")
        XCTAssertEqual(system.name, "Beispiel-System")
        XCTAssertEqual(system.contactEmail, "info@example.org")
        XCTAssertEqual(system.contactName, "Allgemeiner OParl Kontakt")
        XCTAssertEqual(system.website, "http://www.example.org/")
        XCTAssertEqual(system.vendor, "http://example-software.com/")
        XCTAssertEqual(system.product, "http://example-software.com/oparl-server/")
        XCTAssertEqual(system.otherOparlVersions?.count, 1)
        XCTAssertNotNil(system.created)
        XCTAssertNotNil(system.modified)
        
    }
    
}
