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
        dateFormatter.dateFormat = format
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        return dateFormatter.date(from: dateString)!
    }
    
}

@MainActor
final class RubbishGroupingMonthTests: XCTestCase {
    
    func test_grouping() async {
        
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
        let calendar = Calendar.autoupdatingCurrent
        let firstJanuary = calendar.dateComponents([.day, .month, .year], from: items[0].date)
        let fifthJanuary = calendar.dateComponents([.day, .month, .year], from: items[2].date)
        let fifthFebruary = calendar.dateComponents([.day, .month, .year], from: items[3].date)
        let eighthMay = calendar.dateComponents([.day, .month, .year], from: items[4].date)
        XCTAssertEqual(grouped[firstJanuary]?.count, 2)
        XCTAssertEqual(grouped[fifthJanuary]?.count, 1)
        XCTAssertEqual(grouped[fifthFebruary]?.count, 1)
        XCTAssertEqual(grouped[eighthMay]?.count, 1)
        
        print(grouped)
        
    }
    
}
