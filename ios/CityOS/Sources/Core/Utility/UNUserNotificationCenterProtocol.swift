//
//  UNUserNotificationCenterProtocol.swift
//
//
//  Created by Lennart Fischer on 06.01.21.
//

import Foundation
import UserNotifications

@MainActor
public protocol UNUserNotificationCenterProtocol: AnyObject, Sendable {
    
    func add(_ request: UNNotificationRequest) async throws
    
    func removeAllPendingNotificationRequests()
    
    func pendingNotificationRequests() async -> [UNNotificationRequest]

    func getPendingNotificationRequests(completionHandler: @escaping @Sendable ([UNNotificationRequest]) -> Void)
    
    func removePendingNotificationRequests(withIdentifiers: [String])
    
}

extension UNUserNotificationCenter: UNUserNotificationCenterProtocol {
    
}
