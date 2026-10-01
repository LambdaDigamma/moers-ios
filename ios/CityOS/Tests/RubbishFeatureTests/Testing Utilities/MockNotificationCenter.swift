//
//  MockNotificationCenter.swift
//  MMRubbish
//
//  Created by Lennart Fischer on 05.04.19.
//  Copyright © 2019 LambdaDigamma. All rights reserved.
//

import XCTest
import UserNotifications
import Core
@testable import RubbishFeature

@MainActor
final class MockNotificationCenter: UNUserNotificationCenterProtocol {
    
    var addRequestExpectation: XCTestExpectation?
    var removeAllExpectation: XCTestExpectation?
    var getPendingRequestsExpectation: XCTestExpectation?
    var removePendingExpectation: XCTestExpectation?
    
    var pendingNotifications: [UNNotificationRequest] = []
    var removedIdentifiers: [String] = []
    
    func add(_ request: UNNotificationRequest) async throws {
        
        addRequestExpectation?.fulfill()
        pendingNotifications.append(request)
        
    }
    
    func removeAllPendingNotificationRequests() {

        removeAllExpectation?.fulfill()
        
    }

    func pendingNotificationRequests() async -> [UNNotificationRequest] {
        XCTFail("Use getPendingNotificationRequests(completionHandler:) for rubbish reminder invalidation.")
        return pendingNotifications
    }
    
    func getPendingNotificationRequests(completionHandler: @escaping @Sendable ([UNNotificationRequest]) -> Void) {
        
        getPendingRequestsExpectation?.fulfill()
        completionHandler(pendingNotifications)
        
    }
    
    func removePendingNotificationRequests(withIdentifiers: [String]) {
        removedIdentifiers.append(contentsOf: withIdentifiers)
        pendingNotifications.removeAll { request in
            withIdentifiers.contains(request.identifier)
        }
        removePendingExpectation?.fulfill()
    }
    
}
