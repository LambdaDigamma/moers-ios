//
//  MockNotificationCenter.swift
//  MMRubbish
//
//  Created by Lennart Fischer on 05.04.19.
//  Copyright © 2019 LambdaDigamma. All rights reserved.
//

import XCTest
import UserNotifications
import MMCommon
@testable import RubbishFeature

class MockNotificationCenter: UNUserNotificationCenterProtocol {
    
    var addRequestExpectation: XCTestExpectation?
    var removeAllExpectation: XCTestExpectation?
    
    func add(_ request: UNNotificationRequest,
             withCompletionHandler completionHandler: ((Error?) -> Void)?) {
        
        addRequestExpectation?.fulfill()
        
        completionHandler?(nil)
        
    }
    
    func removeAllPendingNotificationRequests() {

        removeAllExpectation?.fulfill()
        
    }
    
    func getPendingNotificationRequests(completionHandler: @escaping ([UNNotificationRequest]) -> Void) {
        
        // TODO: Implement this
        
    }
    
    func removePendingNotificationRequests(withIdentifiers: [String]) {
        
    }
    
}
