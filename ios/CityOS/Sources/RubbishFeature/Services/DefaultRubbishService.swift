//
//  DefaultRubbishService.swift
//  
//
//  Created by Lennart Fischer on 14.12.21.
//

import Foundation
import UserNotifications
import Core
import ModernNetworking

#if canImport(WidgetKit)
import WidgetKit
#endif

@MainActor
public class DefaultRubbishService: RubbishService {
    
    private let client: any HTTPClient
    private var notificationCenter: UNUserNotificationCenterProtocol
    private let decoder: JSONDecoder
    private let session = URLSession.shared
//    private let storagePickupItemsManager: AnyStoragable<RubbishPickupItem>
//    private let storageStreetsManager: AnyStoragable<RubbishCollectionStreet>
    private let storageKeyStreets = "streets"
    private let storageKeyPickups = "pickups"
    private var requests: [UNNotificationRequest] = []
    
    public init(
        client: any HTTPClient,
        notificationCenter: UNUserNotificationCenterProtocol = UNUserNotificationCenter.current(),
        userDefaults: UserDefaults = .standard
//        storagePickupItemsManager: AnyStoragable<RubbishPickupItem> = NoCache(),
//        storageStreetsManager: AnyStoragable<RubbishCollectionStreet> = NoCache()
    ) {
        
        self.client = client
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .formatted(formatter)

//        self.storageStreetsManager = storageStreetsManager
//        self.storagePickupItemsManager = storagePickupItemsManager
        self.notificationCenter = notificationCenter
        self.configureUserDefaultsBackedStorage(userDefaults)
        
    }

    @MainActor
    public convenience init(
        loader: HTTPLoader,
        notificationCenter: UNUserNotificationCenterProtocol = UNUserNotificationCenter.current(),
        userDefaults: UserDefaults = .standard
    ) {
        self.init(
            client: HTTPLoaderClient(loader: loader),
            notificationCenter: notificationCenter,
            userDefaults: userDefaults
        )
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
    
    public func loadRubbishCollectionStreets() async throws -> [RubbishCollectionStreet] {
        let request = HTTPRequest(
            method: .get,
            path: "/api/v2/rubbish/streets",
            queryItems: [URLQueryItem(name: "all", value: "1")]
        )
        
        let result = await client.load(request)
        let items = try await result.decoding([RubbishCollectionStreet].self)
        
        let sorted = items.sorted { lhs, rhs in
            return lhs.displayName < rhs.displayName
        }
        
        return sorted
    }
    
    public func loadRubbishPickupItems(
        for street: RubbishCollectionStreet
    ) async throws -> [RubbishPickupItem] {
        let request = HTTPRequest(
            method: .get,
            path: "/api/v2/rubbish/streets/\(street.id)/pickups"
        )
        
        do {
            let result = await client.load(request)
            let items = try await result.decoding([RubbishPickupItem].self)
            return items
        } catch {
            let apiError = error as? APIError ?? APIError.networkError(error)
            throw RubbishLoadingError.internalError(apiError)
        }
    }
    
    // MARK: - Notifications
    
    public func registerNotifications(at hour: Int, minute: Int) {
        
        self.reminderHour = hour
        self.reminderMinute = minute
        self.remindersEnabled = true
        
        Task {
            guard let rubbishStreet = self.rubbishStreet else {
                return
            }
            
            do {
                let items = try await self.loadRubbishPickupItems(for: rubbishStreet)
                
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
                await self.scheduleNextNotification()
                
            } catch {
                print("Scheduling reminders failed: \(error.localizedDescription)")
            }
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
        let notificationCenter = self.notificationCenter

        notificationCenter.getPendingNotificationRequests { requests in
            
            let requestIdentifiers = requests
                .filter { $0.identifier.contains("RubbishReminder") }
                .map { $0.identifier }
            
            Task { @MainActor in
                notificationCenter.removePendingNotificationRequests(withIdentifiers: requestIdentifiers)
            }
        }
    }
    
    private func scheduleNextNotification() async {
        if let request = requests.popLast() {
            await scheduleNotification(request: request)
            await scheduleNextNotification()
        } else {
            let requests = await notificationCenter.pendingNotificationRequests()
            print("Scheduled \(requests.count) notifications")
        }
    }
    
    private func scheduleNotification(request: UNNotificationRequest) async {
        do {
            try await notificationCenter.add(request)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    // MARK: - Testing
    
    private func registerTestNotification() async throws {
        
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
        
        try await notificationCenter.add(request)
        
    }
    
    public func setupBadSetup() {
        
        self.street = "Muster"
        self.id = nil
        self.streetAddition = nil
        
    }
    
    // MARK: - Saving of Settings

    private func configureUserDefaultsBackedStorage(_ userDefaults: UserDefaults) {
        _street.storage = userDefaults
        _streetAddition.storage = userDefaults
        _id.storage = userDefaults
        _residualWaste.storage = userDefaults
        _organicWaste.storage = userDefaults
        _paperWaste.storage = userDefaults
        _yellowBag.storage = userDefaults
        _greenWaste.storage = userDefaults
        _sweeperDay.storage = userDefaults
        _year.storage = userDefaults
        _isEnabled.storage = userDefaults
        _remindersEnabled.storage = userDefaults
        _reminderHour.storage = userDefaults
        _reminderMinute.storage = userDefaults
    }
    
    @UserDefaultsBacked(key: "RubbishStreet")
    public var street: String?
    
    @UserDefaultsBacked(key: "RubbishStreetAddition")
    internal var streetAddition: String?
    
    @UserDefaultsBacked(key: "RubbishStreetID")
    internal var id: Int?
    
    @UserDefaultsBacked(key: "RubbishResidualWaste")
    internal var residualWaste: Int?
    
    @UserDefaultsBacked(key: "RubbishOrganicWaste")
    internal var organicWaste: Int?
    
    @UserDefaultsBacked(key: "RubbishPaperWaste")
    internal var paperWaste: Int?
    
    @UserDefaultsBacked(key: "RubbishYellowBag")
    internal var yellowBag: Int?
    
    @UserDefaultsBacked(key: "RubbishGreenWaste")
    internal var greenWaste: Int?
    
    @UserDefaultsBacked(key: "RubbishSweeperDay")
    internal var sweeperDay: String?
    
    @UserDefaultsBacked(key: "RubbishStreetYear")
    internal var year: Int?
    
    @UserDefaultsBacked(
        key: "RubbishEnabled",
        defaultValue: false
    )
    public var isEnabled: Bool
    
    @UserDefaultsBacked(
        key: "RubbishRemindersEnabled",
        defaultValue: false
    )
    public var remindersEnabled: Bool
    
    @UserDefaultsBacked(key: "RubbishReminderHour")
    public var reminderHour: Int?
    
    @UserDefaultsBacked(key: "RubbishReminderMinute")
    public var reminderMinute: Int?

    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}
}
