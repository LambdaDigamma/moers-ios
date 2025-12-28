//
//  UNUserNotificationCenterProtocol.swift
//
//
//  Created by Lennart Fischer on 06.01.21.
//

import Foundation
import UserNotifications

public protocol UNUserNotificationCenterProtocol: AnyObject {
    
    func add(_ request: UNNotificationRequest) async throws
    
    func removeAllPendingNotificationRequests()
    
    func pendingNotificationRequests() async -> [UNNotificationRequest]
    
    func removePendingNotificationRequests(withIdentifiers: [String])
    
}

extension UNUserNotificationCenter: UNUserNotificationCenterProtocol {
    
}
