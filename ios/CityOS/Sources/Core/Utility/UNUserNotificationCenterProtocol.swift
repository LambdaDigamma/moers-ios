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

public extension UNUserNotificationCenterProtocol {
    
    func add(_ request: UNNotificationRequest) async throws {
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            self.add(request) { error in
                if let error = error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume()
                }
            }
        }
    }
    
    func pendingNotificationRequests() async -> [UNNotificationRequest] {
        await withCheckedContinuation { (continuation: CheckedContinuation<[UNNotificationRequest], Never>) in
            self.getPendingNotificationRequests { requests in
                continuation.resume(returning: requests)
            }
        }
    }
    
}

extension UNUserNotificationCenter: UNUserNotificationCenterProtocol { }
