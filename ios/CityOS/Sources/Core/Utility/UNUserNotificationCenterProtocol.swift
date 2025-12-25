//
//  UNUserNotificationCenterProtocol.swift
//
//
//  Created by Lennart Fischer on 06.01.21.
//

import Foundation
import UserNotifications

public protocol UNUserNotificationCenterProtocol: AnyObject {
    
    func add(_ request: UNNotificationRequest, withCompletionHandler completionHandler: ((Error?) -> Void)?)
    
    func removeAllPendingNotificationRequests()
    
    func getPendingNotificationRequests(completionHandler: @escaping ([UNNotificationRequest]) -> Void)
    
    func removePendingNotificationRequests(withIdentifiers: [String])
    
}

extension UNUserNotificationCenter: UNUserNotificationCenterProtocol { }
