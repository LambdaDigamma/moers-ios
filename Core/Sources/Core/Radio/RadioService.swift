//
//  RadioService.swift
//  
//
//  Created by Lennart Fischer on 21.09.21.
//

import Foundation
import Combine
import OSLog

#if canImport(UserNotifications)
import UserNotifications
#endif

public protocol RadioServiceProtocol: AnyObject {
    
    func load() -> AnyPublisher<[RadioBroadcast], Error>
    
}

public class RadioService: RadioServiceProtocol {
    
    public static let shared: RadioService = RadioService()
    
    public let url: URL
    
    private let logger: Logger = Logger(.coreApi)
    private let notificationThreshold: TimeInterval = 5 * 60 // 5 min
    private let radioThreadIdentifier = "threadRadio"
    private let notificationCenter: UNUserNotificationCenter = .current()
    
    private var cancellables = Set<AnyCancellable>()
    
    public init() {
        self.url = URL(string: "https://stream.lokalradio.nrw/444zcn3")!
    }
    
    public init(url: URL) {
        self.url = url
    }
    
    public func load() -> AnyPublisher<[RadioBroadcast], Error> {
        
        let request = URLRequest(url: URL(string: "https://moers.app/api/v1/radio-broadcasts")!)
        let session = URLSession.shared
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        
        decoder.keyDecodingStrategy = .useDefaultKeys
        decoder.dateDecodingStrategy = .formatted(formatter)
        
        return session
            .dataTaskPublisher(for: request)
            .map { $0.data }
            .decode(type: MessageDataResponse<[RadioBroadcast]>.self, decoder: decoder)
            .map(\.data)
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
            
    }
    
    // MARK: - Reminder
    
    #if canImport(UserNotifications)
    
    public func toggleReminder(for broadcast: RadioBroadcast, completion: (_ reminderIsEnabled: Bool) -> Void) {
        
//        notificationCenter.getPendingNotificationRequests { (requests: [UNNotificationRequest]) in
//
//            let broadcastIdentifier = self.reminderIdentifier(for: broadcast)
//
//            if requests.contains(where: { $0.identifier == broadcastIdentifier }) {
//                self.notificationCenter.removePendingNotificationRequests(withIdentifiers: [broadcastIdentifier])
//                completion(false)
//            } else {
//                self.scheduleReminder(for: broadcast)
//                completion(true)
//            }
//
//        }
        
    }
    
    public func scheduleReminder(for broadcast: RadioBroadcast) {
        
        guard let startsAt = broadcast.startsAt else { return }
        
        let content = notificationContent(for: broadcast)
        
        let calendar = Calendar.autoupdatingCurrent
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute],
                                from: startsAt.addingTimeInterval(-notificationThreshold))
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: reminderIdentifier(for: broadcast),
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { [weak self] (error: Error?) in
            if let error = error {
                self?.logger.error("Adding radio broadcast reminder failed: \(error.localizedDescription)")
            } else {
                self?.logger.info("Adding radio broadcast reminder was successful.")
            }
        }
        
    }
    
    public func sendTestNotification(for broadcast: RadioBroadcast, in timeInterval: TimeInterval = 10) {
        
        let content = notificationContent(for: broadcast)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: timeInterval, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: reminderIdentifier(for: broadcast),
            content: content,
            trigger: trigger
        )
        
        self.registerNotification(request: request)
        
    }
    
    private func registerNotification(request: UNNotificationRequest) {
        
        UNUserNotificationCenter.current().add(request) { [weak self] (error: Error?) in
            if let error = error {
                self?.logger.error("Adding radio broadcast reminder failed: \(error.localizedDescription)")
            } else {
                self?.logger.info("Adding radio broadcast reminder was successful.")
            }
        }
        
    }
    
    private func notificationContent(for broadcast: RadioBroadcast) -> UNMutableNotificationContent {
        
        let content = UNMutableNotificationContent()
        content.title = broadcast.title
        content.body = "Die Sendung «\(broadcast.title)» beginnt in 5 Minuten. \nViel Spaß beim Hören!"
        content.sound = .defaultCritical
        content.threadIdentifier = radioThreadIdentifier
        
        return content
        
    }
    
    private func reminderIdentifier(for broadcast: RadioBroadcast) -> String {
        return "Reminder-RadioBroadcast-\(broadcast.id)"
    }
    
    #endif
    
}
