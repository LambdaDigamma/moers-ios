//
//  DefaultTripService.swift
//  
//
//  Created by Lennart Fischer on 15.12.22.
//

import Foundation

public struct Session: Codable, Equatable, Hashable {
    
    public let sessionID: String
    public let requestID: String
    
    public init(sessionID: String, requestID: String) {
        self.sessionID = sessionID
        self.requestID = requestID
    }
    
    public static let new = Session(sessionID: "0", requestID: "1")
    
}

public struct Trip: Codable {
    
    public let session: Session
    
    public init(session: Session) {
        self.session = session
    }
    
}

public class DefaultTripService {
    
    private let path: URL
    private let disk: DiskStorage
    private let storage: CodableStorage
    private let notificationCenter: NotificationCenter
    
    private let tripKey = "currentTrip"
    private let rawTripKey = "currentTripRaw"
    
    public init(notificationCenter: NotificationCenter = .default) {
        
        self.path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first ?? URL(fileURLWithPath: NSTemporaryDirectory())
        self.disk = DiskStorage(path: path)
        self.storage = CodableStorage(storage: disk)
        self.notificationCenter = notificationCenter
        
    }
    
    public func activate(trip: CachedEFATrip) {
        
        self.currentTrip = trip
        self.notificationCenter.post(Notification(name: .activatedTrip))
        
    }
    
    public func resetTrip() {
        self.currentTrip = nil
        self.notificationCenter.post(Notification(name: .deactivatedTrip))
    }
    
    // MARK: - Storing -
    
    public var currentTrip: CachedEFATrip? {
        get {
            return self.load()
        }
        set {
            self.save(trip: newValue)
        }
    }
    
    private func load() -> CachedEFATrip? {
        
        do {
            return try storage.fetch(for: tripKey)
        } catch {
            return nil
        }
        
    }
    
    private func save(trip: CachedEFATrip?) {
        
        do {
            try storage.save(trip, for: tripKey)
        } catch {
            print(error)
        }
        
    }
    
    private func saveRaw(data: Data) {
        
        do {
            try self.disk.save(value: data, for: rawTripKey)
        } catch {
            print(error)
        }
        
    }
    
}
