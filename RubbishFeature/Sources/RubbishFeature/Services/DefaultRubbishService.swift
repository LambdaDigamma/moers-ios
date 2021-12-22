//
//  DefaultRubbishService.swift
//  
//
//  Created by Lennart Fischer on 14.12.21.
//

import Foundation
import UserNotifications
import MMCommon
import Combine

public class DefaultRubbishService: RubbishService {
    
    public init(
        notificationCenter: MMCommon.UNUserNotificationCenterProtocol = UNUserNotificationCenter.current()
//        storagePickupItemsManager: AnyStoragable<RubbishPickupItem> = NoCache(),
//        storageStreetsManager: AnyStoragable<RubbishCollectionStreet> = NoCache()
    ) {
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .formatted(formatter)

//        self.storageStreetsManager = storageStreetsManager
//        self.storagePickupItemsManager = storagePickupItemsManager
        self.notificationCenter = notificationCenter
        self.registerDefaultURLs()
        
    }
    
    private var notificationCenter: MMCommon.UNUserNotificationCenterProtocol
    private let decoder: JSONDecoder
    private let session = URLSession.shared
//    private let storagePickupItemsManager: AnyStoragable<RubbishPickupItem>
//    private let storageStreetsManager: AnyStoragable<RubbishCollectionStreet>
    private let storageKeyStreets = "streets"
    private let storageKeyPickups = "pickups"
    private var cancellables = Set<AnyCancellable>()
    
    public var rubbishStreetURL: URL?
    public var rubbishDateURL: URL?
    private var requests: [UNNotificationRequest] = []
    
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
        
    }
    
    public func loadRubbishCollectionStreets() -> AnyPublisher<[RubbishCollectionStreet], Error> {
        
        return Just([])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        
//        return Deferred {
//            Future { promise in
//
//                let request = URLRequest(url: URL(string: MMAPIConfig.baseURL.appending("rubbish/streets?all"))!)
//
//                let task = self.session.dataTask(with: request) { (data, response, error) in
//
//                    if let error = error {
//                        return promise(.failure(error))
//                    }
//
//                    guard let data = data else {
//                        return promise(.failure(APIError.noData))
//                    }
//
//                    self.storageStreetsManager.setLastReload(Date(), forKey: self.storageKeyStreets)
//                    self.storageStreetsManager.write(data: data, forKey: self.storageKeyStreets)
//
//                    let decodedStreets = self.decodeStreets(from: data)
//
//                    decodedStreets.sink { (completion: Subscribers.Completion<Error>) in
//
//                        switch completion {
//                            case .failure(let error):
//                                return promise(.failure(error))
//                            default: break
//                        }
//
//                    } receiveValue: { (streets: [RubbishCollectionStreet]) in
//                        return promise(.success(streets))
//                    }
//                    .store(in: &self.cancellables)
//
//                }
//
//                task.resume()
//
//            }
//        }
//        .eraseToAnyPublisher()
        
    }
    
    public func loadRubbishPickupItems(for street: RubbishCollectionStreet) -> AnyPublisher<[RubbishPickupItem], Error> {
        
        return Just([])
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
        
//        return Deferred {
//            Future { promise in
//
//                let endpoint = "rubbish/streets/\(street.id)/pickups"
//
//                let request = URLRequest(url: URL(string: MMAPIConfig.baseURL.appending(endpoint))!)
//
//                let task = self.session.dataTask(with: request) { (data, response, error) in
//
//                    if let error = error {
//                        return promise(.failure(error))
//                    }
//
//                    guard let data = data else {
//                        return promise(.failure(APIError.noData))
//                    }
//
//                    self.storagePickupItemsManager.setLastReload(Date(), forKey: self.storageKeyPickups)
//                    self.storagePickupItemsManager.write(data: data, forKey: self.storageKeyPickups)
//
//                    let decodedPickupItems = self.decodePickupItems(from: data)
//
//                    decodedPickupItems.sink { (completion: Subscribers.Completion<Error>) in
//
//                        switch completion {
//                            case .failure(let error):
//                                return promise(.failure(error))
//                            default: break
//                        }
//
//                    } receiveValue: { (pickupItems: [RubbishPickupItem]) in
//                        return promise(.success(pickupItems))
//                    }
//                    .store(in: &self.cancellables)
//
//                }
//
//                task.resume()
//
//            }
//        }
//        .eraseToAnyPublisher()
        
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
    
    // MARK: - Private Methods
    
    private func registerDefaultURLs() {
        
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
            
            items.sink { (completion: Combine.Subscribers.Completion<Error>) in
                
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
                    notificationContent.title = String.localized("RubbishCollectionNotificationTitle")
                    notificationContent.body = String.localized("RubbishCollectionNotificationBody") + RubbishWasteType.localizedForCase(item.type)
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
        notificationContent.subtitle = "Morgen wird abgeholt: \(item.type.rawValue)"
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
        
        self.street = "Adler"
        self.id = nil
        self.streetAddition = nil
        
    }
    
    // MARK: - Saving of Settings
    
    @MMCommon.UserDefaultsBacked(key: "RubbishStreet")
    public var street: String?
    
    @MMCommon.UserDefaultsBacked(key: "RubbishStreetAddition")
    internal var streetAddition: String?
    
    @MMCommon.UserDefaultsBacked(key: "RubbishStreetID")
    internal var id: Int?
    
    @MMCommon.UserDefaultsBacked(key: "RubbishResidualWaste")
    internal var residualWaste: Int?
    
    @MMCommon.UserDefaultsBacked(key: "RubbishOrganicWaste")
    internal var organicWaste: Int?
    
    @MMCommon.UserDefaultsBacked(key: "RubbishPaperWaste")
    internal var paperWaste: Int?
    
    @MMCommon.UserDefaultsBacked(key: "RubbishYellowBag")
    internal var yellowBag: Int?
    
    @MMCommon.UserDefaultsBacked(key: "RubbishGreenWaste")
    internal var greenWaste: Int?
    
    @MMCommon.UserDefaultsBacked(key: "RubbishSweeperDay")
    internal var sweeperDay: String?
    
    @MMCommon.UserDefaultsBacked(key: "RubbishStreetYear")
    internal var year: Int?
    
    @MMCommon.UserDefaultsBacked(key: "RubbishEnabled", defaultValue: false)
    public var isEnabled: Bool
    
    @MMCommon.UserDefaultsBacked(key: "RubbishRemindersEnabled", defaultValue: false)
    public var remindersEnabled: Bool
    
    @MMCommon.UserDefaultsBacked(key: "RubbishReminderHour")
    public var reminderHour: Int?
    
    @MMCommon.UserDefaultsBacked(key: "RubbishReminderMinute")
    public var reminderMinute: Int?
    
}
