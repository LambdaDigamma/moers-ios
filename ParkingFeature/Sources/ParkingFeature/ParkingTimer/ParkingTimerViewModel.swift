//
//  ParkingTimerViewModel.swift
//  
//
//  Created by Lennart Fischer on 02.04.22.
//

import SwiftUI
import Core
import CoreLocation
import Resolver
import Combine

public class ParkingTimerViewModel: StandardViewModel {
    
    @LazyInjected var locationService: LocationService
    
    @Published var endDate: Date = Date()
    @Published var timerStarted: Bool = false
    
    @Published var time: TimeInterval = 30 * 60
    @Published var enableNotifications: Bool = true
    @Published var saveParkingLocation: Bool = true
    @Published var carPosition: CLLocationCoordinate2D?
    
    public var currentEstimatedEndDate: Date {
        return Date(timeIntervalSinceNow: time)
    }
    
    public override init() {
        super.init()
        self.setupObservers()
    }
    
    public init(
        data: ParkingTimerData
    ) {
        super.init()
        self.timerStarted = true
        self.endDate = data.endDate
        self.enableNotifications = data.shouldSendNotifications
        self.saveParkingLocation = data.carPosition != nil
        self.carPosition = data.carPosition?.toCoordinate()
    }
    
    @discardableResult
    public func decrementTime() -> Bool {
        
        if time >= 10 * 60 {
            time -= 5 * 60
            return true
        } else {
            return false
        }
        
    }
    
    @discardableResult
    public func incrementTime() -> Bool {
        
        if time <= 12 * 61 * 60 {
            time += 5 * 60
            return true
        } else {
            return false
        }
        
    }
    
    public var decrementDisabled: Bool {
        return time == 5 * 60
    }
    
    public var incrementDisabled: Bool {
        return time == 12 * 60 * 60
    }
    
    private func setupObservers() {
        
        self.$time
            .receive(on: DispatchQueue.main)
            .sink { (time: TimeInterval) in
                if !self.timerStarted {
                    self.endDate = Date(timeIntervalSinceNow: time)
                }
            }
            .store(in: &cancellables)
        
        self.$saveParkingLocation
            .receive(on: DispatchQueue.main)
            .filter({ $0 == true })
            .sink { _ in
                if !self.timerStarted {
                    self.loadCurrentLocation()
                }
            }
            .store(in: &cancellables)
        
        self.locationService.location.sink { (_: Subscribers.Completion<Error>) in
            
        } receiveValue: { (location: CLLocation) in
            if !self.timerStarted {
                self.carPosition = location.coordinate
            }
        }
        .store(in: &cancellables)

        
    }
    
    public func loadCurrentLocation() {
        
        self.locationService.requestCurrentLocation()
        self.carPosition = locationService.location.value.coordinate
        
    }
    
    public func startTimer() {
        
        self.endDate = Date(timeIntervalSinceNow: time)
        self.carPosition = saveParkingLocation ? carPosition : nil
        
        withAnimation {
            self.timerStarted = true
            self.persistTimer()
        }
    }
    
    public static func loadCurrentOrNew() -> ParkingTimerViewModel {
        
        if let url = Self.buildURL() {
            
            if FileManager.default.fileExists(atPath: url.path) {
                
                do {
                    
                    let data = try Data(contentsOf: url)
                    let encoded = try Self.decode(data: data)
                    
                    return ParkingTimerViewModel(data: encoded)
                    
                } catch {
                    print(error)
                }
                
            }
            
        }
        
        return ParkingTimerViewModel()
        
    }
    
    // MARK: - Persisting -
    
    public struct ParkingTimerData: Codable {
        
        public let endDate: Date
        public let shouldSendNotifications: Bool
        public let carPosition: Point?
        
        public init(
            endDate: Date,
            shouldSendNotifications: Bool,
            carPosition: Point? = nil
        ) {
            self.endDate = endDate
            self.shouldSendNotifications = shouldSendNotifications
            self.carPosition = carPosition
        }
        
        public enum CodingKeys: String, CodingKey {
            case endDate = "end_date"
            case shouldSendNotifications = "should_send_notifications"
            case carPosition = "car_position"
        }
        
    }
    
    public func persistTimer() {
        
        let data = ParkingTimerData(
            endDate: self.endDate,
            shouldSendNotifications: self.enableNotifications,
            carPosition: self.carPosition?.toPoint()
        )
        
        guard let encodedData = try? Self.encode(data: data) else { return }
        guard let url = Self.buildURL() else { return }
        
        do {
            try encodedData.write(to: url)
        } catch {
            print(error)
        }
        
    }
    
    public static func resetCurrent() {
        
        guard let url = Self.buildURL() else { return }
        
        do {
            try FileManager.default.removeItem(at: url)
        } catch {
            print(error)
        }
        
    }
    
    private static func buildURL() -> URL? {
        
        guard let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        return documentsPath.appendingPathComponent("current_parking_timer").appendingPathExtension("json")
        
    }
    
    public static func encode(data: ParkingTimerData, prettyPrinted: Bool = false) throws -> Data {
        
        let encoder = JSONEncoder()
        
        encoder.dateEncodingStrategy = .formatted(Self.dateFormatter)
        encoder.outputFormatting = prettyPrinted ? [.prettyPrinted, .withoutEscapingSlashes, .sortedKeys] : []
        
        return try encoder.encode(data)
        
    }
    
    public static func decode(data: Data) throws -> ParkingTimerData {
        
        let decoder = JSONDecoder()
        
        decoder.dateDecodingStrategy = .formatted(dateFormatter)
        
        return try decoder.decode(ParkingTimerData.self, from: data)
        
    }
    
    public static let dateFormatter: DateFormatter = {
        let decoder = JSONDecoder()
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z"
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        return formatter
    }()
    
}
