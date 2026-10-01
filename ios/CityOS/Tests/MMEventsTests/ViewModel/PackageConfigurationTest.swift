//
//  PackageConfigurationTest.swift
//  
//
//  Created by Lennart Fischer on 07.01.21.
//

import XCTest
import ModernNetworking
import Combine
@testable import MMEvents


@MainActor
final class PackageConfigurationTest: XCTestCase {
    
    func testEventActiveThresholdSaving() async {
        
        XCTAssertEqual(EventPackageConfiguration.eventActiveMinuteThreshold,
                       Measurement<UnitDuration>(value: 30, unit: .minutes))
        
        EventPackageConfiguration.eventActiveMinuteThreshold = Measurement(value: 60, unit: .minutes)
        
        XCTAssertEqual(EventPackageConfiguration.eventActiveMinuteThreshold,
                       Measurement<UnitDuration>(value: 60, unit: .minutes))
        
    }
    
}
