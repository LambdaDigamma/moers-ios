//
//  RubbishGroupingMonthTests.swift
//  
//
//  Created by Lennart Fischer on 02.02.22.
//

import Foundation
import XCTest
@testable import RubbishFeature

extension Date {
    
    public static func mock(_ dateString: String, format: String = "dd/MM/yy") -> Date {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yy"
        return dateFormatter.date(from: dateString)!
    }
    
}

final class RubbishGroupingMonthTests: XCTestCase {
    
    func test_grouping() {
        
        let items: [RubbishPickupItem] = [
            .init(date: Date.mock("01/01/2022"), type: .cuttings),
            .init(date: Date.mock("01/01/2022"), type: .plastic),
            .init(date: Date.mock("05/01/2022"), type: .organic),
            .init(date: Date.mock("05/02/2022"), type: .cuttings),
            .init(date: Date.mock("08/05/2022"), type: .plastic),
        ]
        
        let grouped = items.groupByMonths()
        
        XCTAssertEqual(grouped.keys.count, 4)
        XCTAssertTrue(grouped.keys.contains(where: { $0.month == 1 && $0.year == 2022 }))
        XCTAssertTrue(grouped.keys.contains(where: { $0.month == 2 && $0.year == 2022 }))
        XCTAssertTrue(grouped.keys.contains(where: { $0.month == 5 && $0.year == 2022 }))
        XCTAssertEqual(grouped[DateComponents(year: 2022, month: 1, day: 1)]?.count, 2)
        XCTAssertEqual(grouped[DateComponents(year: 2022, month: 2, day: 5)]?.count, 1)
        XCTAssertEqual(grouped[DateComponents(year: 2022, month: 2, day: 5)]?.count, 1)
        XCTAssertEqual(grouped[DateComponents(year: 2022, month: 5, day: 8)]?.count, 1)
        
        print(grouped)
        
    }
    
}
