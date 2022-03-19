//
//  DefaultRubbishService.swift
//  
//
//  Created by Lennart Fischer on 14.12.21.
//

import Foundation
import UserNotifications
import Core
import Combine
import ModernNetworking

#if canImport(WidgetKit)
import WidgetKit
#endif

public class DefaultRubbishService: RubbishService {
    
    private let loader: HTTPLoader
    private var notificationCenter: UNUserNotificationCenterProtocol
    private let decoder: JSONDecoder
    private let session = URLSession.shared
    private let userDefaults: UserDefaults
//    private let storagePickupItemsManager: AnyStoragable<RubbishPickupItem>
//    private let storageStreetsManager: AnyStoragable<RubbishCollectionStreet>
    private let storageKeyStreets = "streets"
    private let storageKeyPickups = "pickups"
    private var cancellables = Set<AnyCancellable>()
    private var requests: [UNNotificationRequest] = []
    
    public init(
        loader: HTTPLoader,
        notificationCenter: UNUserNotificationCenterProtocol = UNUserNotificationCenter.current(),
        userDefaults: UserDefaults = .standard
//        storagePickupItemsManager: AnyStoragable<RubbishPickupItem> = NoCache(),
//        storageStreetsManager: AnyStoragable<RubbishCollectionStreet> = NoCache()
    ) {
        
        self.loader = loader
        self.userDefaults = userDefaults
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .formatted(formatter)

//        self.storageStreetsManager = storageStreetsManager
//        self.storagePickupItemsManager = storagePickupItemsManager
        self.notificationCenter = notificationCenter
        
    }
    
    public var rubbishStreet: RubbishCollectionStreet? {
        
        guard let id = id else { return nil }
        guard let street = street else { return nil }
        guard let residualWaste = residualWaste else { return nil }
        guard let organicWaste = organicWaste else { return nil }
        guard let paperWaste = paperWaste else { return nil }
        guard let yellowBag = yellowBag else { return nil }
        guard let greenWaste = greenWaste else { return nil }
        guard let year = year else { return nil }
        
        return RubbishCollectionStreet(
            id: id,
            street: street,
            streetAddition: streetAddition,
            residualWaste: residualWaste,
            organicWaste: organicWaste,
            paperWaste: paperWaste,
            yellowBag: yellowBag,
            greenWaste: greenWaste,
            sweeperDay: sweeperDay ?? "",
            year: year
        )
        
    }
    
    // MARK: - Public Methods
    
    public func register(_ street: RubbishCollectionStreet) {
        
        self.id = street.id
        self.street = street.street
        self.streetAddition = street.streetAddition
        self.residualWaste = street.residualWaste
        self.organicWaste = street.organicWaste
        self.paperWaste = street.paperWaste
        self.yellowBag = street.yellowBag
        self.greenWaste = street.greenWaste
        self.sweeperDay = street.sweeperDay
        self.year = street.year
        
        #if canImport(WidgetKit)
        // Reload widgets
        WidgetCenter.shared.reloadAllTimelines()
        #endif
        
    }
    
    public func loadRubbishCollectionStreets() -> AnyPublisher<[RubbishCollectionStreet], Error> {
        
        let request = HTTPRequest(
            method: .get,
            path: "/api/v2/rubbish/streets",
            queryItems: [URLQueryItem(name: "all", value: "1")]
        )
        
        return Deferred {
            return Future { promise in
                self.loader.load(request) { (result: HTTPResult) in
                    result.decoding([RubbishCollectionStreet].self) { (result: Result<[RubbishCollectionStreet], HTTPError>) in
                        switch result {
                            case .success(let items):
                                promise(.success(items))
                            case .failure(let error):
                                promise(.failure(error))
                        }
                    }
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
        
    }
    
    public func loadRubbishPickupItems(
        for street: RubbishCollectionStreet
    ) -> AnyPublisher<[RubbishPickupItem], RubbishLoadingError> {
        
        let request = HTTPRequest(
            method: .get,
            path: "/api/v2/rubbish/streets/\(street.id)/pickups"
        )
        
        return Deferred {
            return Future { promise in
                self.loader.load(request) { (result: HTTPResult) in
                    result.decoding([RubbishPickupItem].self) { (result: Result<[RubbishPickupItem], HTTPError>) in
                        switch result {
                            case .success(let items):
                                promise(.success(items))
                            case .failure(let error):
                                promise(.failure(RubbishLoadingError.internalError(error)))
                        }
                    }
                }
            }
        }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
        
    }
    
    internal func decodeStreets(from data: Data) -> AnyPublisher<[RubbishCollectionStreet], Error> {
        
        return Deferred {
            Future { promise in
                
                do {
                    
                    let streets = try self.decoder.decode([RubbishCollectionStreet].self, from: data)
                    
                    return promise(.success(streets))
                    
                } catch {
                    if let error = error as? DecodingError {
                        print(error)
                    }
                    return promise(.failure(error))
                }
                
            }
        }
        .eraseToAnyPublisher()
        
    }
    
    internal func decodePickupItems(from data: Data) -> AnyPublisher<[RubbishPickupItem], Error> {
        
        return Deferred {
            Future { promise in
                
                do {
                    
                    let pickupItems = try self.decoder.decode([RubbishPickupItem].self, from: data)
                    
                    return promise(.success(pickupItems))
                    
                } catch let error as DecodingError {
                    return promise(.failure(error))
                } catch {
                    print(error.localizedDescription)
                    return promise(.failure(error))
                }
                
            }
        }
        .eraseToAnyPublisher()
        
    }
    
    // MARK: - Notifications
    
    public func registerNotifications(at hour: Int, minute: Int) {
        
        self.reminderHour = hour
        self.reminderMinute = minute
        self.remindersEnabled = true
        
        let queue = OperationQueue()
        
        queue.addOperation {
            
            guard let rubbishStreet = self.rubbishStreet else {
                return
            }
            
            let items = self.loadRubbishPickupItems(for: rubbishStreet)
            
            items.sink { (completion: Combine.Subscribers.Completion<RubbishLoadingError>) in
                
                switch completion {
                    case .failure(let error):
                        print("Scheduling reminders failed: \(error.localizedDescription)")
                    default: break
                }
                
            } receiveValue: { (items: [RubbishPickupItem]) in
                
                // Build Rubbish Collection Notification Requests
                
                for item in items {
                    
                    let notificationContent = UNMutableNotificationContent()
                    
                    notificationContent.badge = 1
                    
#if os(iOS)
                    notificationContent.title = PackageStrings.Notification.title
                    notificationContent.body = PackageStrings.Notification.body + item.type.title
#endif
                    
                    let date = item.date
                    
                    let calendar = Calendar.current
                    
                    var dateComponents = DateComponents()
                    
                    let previousDate = calendar.date(byAdding: .day, value: -1, to: date) ?? Date()
                    
                    dateComponents.day = calendar.component(.day, from: previousDate)
                    dateComponents.month = calendar.component(.month, from: date)
                    dateComponents.year = calendar.component(.year, from: date)
                    dateComponents.hour = self.reminderHour ?? 20
                    dateComponents.minute = self.reminderMinute ?? 0
                    dateComponents.second = 0
                    
                    let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
                    
                    let identifier = "RubbishReminder-\(dateComponents.day ?? 0)-\(dateComponents.month ?? 0)-\(dateComponents.year ?? 0)-\(item.type.rawValue)"
                    
                    let request = UNNotificationRequest(identifier: identifier, content: notificationContent, trigger: trigger)
                    
                    self.requests.append(request)
                    
                }
                
                self.invalidateRubbishReminderNotifications()
                
                // Recursively schedule all Notifications
                
                self.scheduleNextNotification()
                
            }
            .store(in: &self.cancellables)
            
        }
        
    }
    
    public func disableReminder() {
        
        self.invalidateRubbishReminderNotifications()
        self.remindersEnabled = false
        self.reminderHour = 20
        self.reminderMinute = 0
        
    }
    
    public func disableStreet() {
        
        self.street = nil
        self.residualWaste = nil
        self.organicWaste = nil
        self.paperWaste = nil
        self.yellowBag = nil
        self.greenWaste = nil
        self.sweeperDay = nil
        
    }
    
    public func invalidateRubbishReminderNotifications() {
        
        notificationCenter.getPendingNotificationRequests { requests in
            
            let requestIdentifiers = requests
                .filter { $0.identifier.contains("RubbishReminder") }
                .map { $0.identifier }
            
            self.notificationCenter.removePendingNotificationRequests(withIdentifiers: requestIdentifiers)
            
        }
        
        notificationCenter.removeAllPendingNotificationRequests()
        
    }
    
    private func scheduleNextNotification() {
        
        if let request = requests.popLast() {
            self.scheduleNotification(request: request, completion: scheduleNextNotification)
        } else {
            notificationCenter.getPendingNotificationRequests { (requests) in
                print("Scheduled \(requests.count) notifications")
            }
        }
        
    }
    
    private func scheduleNotification(request: UNNotificationRequest, completion: @escaping () -> Void) {
        
        notificationCenter.add(request) { (error) in
            
            if let error = error {
                print(error.localizedDescription)
            } else {
                completion()
            }
            
        }
        
    }
    
    // MARK: - Testing
    
    private func registerTestNotification() {
        
        let date = Date()
        
        let item = RubbishCollectionItem(date: date.format(format: "dd.MM.yyyy"), type: .paper)
        
        let notificationContent = UNMutableNotificationContent()
        
        notificationContent.badge = 1
        
#if canImport(UserNotifications)
#if !os(tvOS)
        notificationContent.title = "Abfuhrkalender"
        notificationContent.subtitle = "Morgen wird abgeholt: \(item.type.title)"
#endif
#endif
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        
        let request = UNNotificationRequest(identifier: "RubbishReminder", content: notificationContent, trigger: trigger)
        
        notificationCenter.add(request, withCompletionHandler: { (error) in
            
            guard let error = error else { return }
            
            print(error.localizedDescription)
            
        })
        
    }
    
    public func setupBadSetup() {
        
        self.street = "Muster"
        self.id = nil
        self.streetAddition = nil
        
    }
    
    // MARK: - Saving of Settings
    
    @UserDefaultsBacked(key: "RubbishStreet", storage: CoreSettings.userDefaults)
    public var street: String?
    
    @UserDefaultsBacked(key: "RubbishStreetAddition", storage: CoreSettings.userDefaults)
    internal var streetAddition: String?
    
    @UserDefaultsBacked(key: "RubbishStreetID", storage: CoreSettings.userDefaults)
    internal var id: Int?
    
    @UserDefaultsBacked(key: "RubbishResidualWaste", storage: CoreSettings.userDefaults)
    internal var residualWaste: Int?
    
    @UserDefaultsBacked(key: "RubbishOrganicWaste", storage: CoreSettings.userDefaults)
    internal var organicWaste: Int?
    
    @UserDefaultsBacked(key: "RubbishPaperWaste", storage: CoreSettings.userDefaults)
    internal var paperWaste: Int?
    
    @UserDefaultsBacked(key: "RubbishYellowBag", storage: CoreSettings.userDefaults)
    internal var yellowBag: Int?
    
    @UserDefaultsBacked(key: "RubbishGreenWaste", storage: CoreSettings.userDefaults)
    internal var greenWaste: Int?
    
    @UserDefaultsBacked(key: "RubbishSweeperDay", storage: CoreSettings.userDefaults)
    internal var sweeperDay: String?
    
    @UserDefaultsBacked(key: "RubbishStreetYear", storage: CoreSettings.userDefaults)
    internal var year: Int?
    
    @UserDefaultsBacked(
        key: "RubbishEnabled",
        defaultValue: false,
        storage: CoreSettings.userDefaults
    )
    public var isEnabled: Bool
    
    @UserDefaultsBacked(
        key: "RubbishRemindersEnabled",
        defaultValue: false,
        storage: CoreSettings.userDefaults
    )
    public var remindersEnabled: Bool
    
    @UserDefaultsBacked(key: "RubbishReminderHour", storage: CoreSettings.userDefaults)
    public var reminderHour: Int?
    
    @UserDefaultsBacked(key: "RubbishReminderMinute", storage: CoreSettings.userDefaults)
    public var reminderMinute: Int?
    
}
