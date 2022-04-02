//
//  ParkingTimerViewModelTests.swift
//  
//
//  Created by Lennart Fischer on 02.04.22.
//

import XCTest
import Core
import Resolver
@testable import ParkingFeature
import CoreLocation

class ParkingTimerViewModelTests: XCTestCase {
    
    private var persistanceURL: URL!
    
    override func setUp() {
        Resolver.register { StaticLocationService() as LocationService }
        persistanceURL = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)
            .first!
            .appendingPathComponent("current_parking_timer")
            .appendingPathExtension("json")
    }
    
    func testInit() {
        
        let viewModel = ParkingTimerViewModel()
        
        XCTAssertNil(viewModel.carPosition)
        
    }
    
    func testLoad() {
        
        let viewModel = ParkingTimerViewModel()
        XCTAssertNil(viewModel.carPosition)
        
        viewModel.loadCurrentLocation()
        XCTAssertNotNil(viewModel.carPosition)
    }
    
    func testDecrement() {
        
        let viewModel = ParkingTimerViewModel()
        
        viewModel.time = 10 * 60
        viewModel.decrementTime()
        
        XCTAssertEqual(viewModel.time, 5 * 60)
        XCTAssertTrue(viewModel.decrementDisabled)
        
    }
    
    func testIncrement() {
        
        let viewModel = ParkingTimerViewModel()
        
        viewModel.time = 12 * 60 * 60 - 5 * 60
        viewModel.incrementTime()
        
        XCTAssertEqual(viewModel.time, 12 * 60 * 60)
        XCTAssertTrue(viewModel.incrementDisabled)
        
    }
    
    func testStartTimer() {
        
        let viewModel = ParkingTimerViewModel()
        XCTAssertFalse(viewModel.timerStarted)
        
        viewModel.startTimer()
        XCTAssertTrue(viewModel.timerStarted)
        
    }
    
    func testEncodeParkingTimerData() throws {
        
        guard let date = ParkingTimerViewModel.dateFormatter.date(from: "2022-04-02T13:24:30.644Z") else {
            return XCTFail("Failed parsing")
        }
        
        let parkingTimer = ParkingTimerViewModel.ParkingTimerData(
            endDate: date,
            shouldSendNotifications: true,
            carPosition: Point(latitude: 51, longitude: 26)
        )
        
        let data = try ParkingTimerViewModel.encode(data: parkingTimer, prettyPrinted: true)
        let string = String(data: data, encoding: .utf8)
        
        XCTAssertEqual(string, """
        {
          "car_position" : {
            "coordinates" : [
              26,
              51
            ],
            "type" : "Point"
          },
          "end_date" : "2022-04-02T13:24:30.644Z",
          "should_send_notifications" : true
        }
        """)
        
    }
    
    func testDecodeParkingTimerData() throws {
        
        let string = """
        {
          "end_date" : "2022-04-02T13:24:30.644Z",
          "should_send_notifications" : false,
          "car_position": {
            "type": "Point",
            "coordinates": [
                51.0,
                7.0
            ]
          }
        }
        """
        
        let data = try ParkingTimerViewModel.decode(data: string.data(using: .utf8)!)
        
        XCTAssertEqual(data.shouldSendNotifications, false)
        XCTAssertNotNil(data.carPosition)
        
    }
    
    func testPersistingViewModel() throws {
        
        try FileManager.default.removeItemIfExists(at: persistanceURL)
        
        XCTAssertFalse(FileManager.default.fileExists(atPath: persistanceURL.path))
        
        let viewModel = ParkingTimerViewModel()
        
        viewModel.persistTimer()
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: persistanceURL.path))
        
    }
    
    func testResetCurrentViewModel() {
        
        let viewModel = ParkingTimerViewModel()
        
        viewModel.persistTimer()
        
        XCTAssertTrue(FileManager.default.fileExists(atPath: persistanceURL.path))
        
        ParkingTimerViewModel.resetCurrent()
        
        XCTAssertFalse(FileManager.default.fileExists(atPath: persistanceURL.path))
        
    }
    
    func testLoadsRightModelIfOneExists() {
        
        let viewModel = ParkingTimerViewModel()
        viewModel.saveParkingLocation = false
        viewModel.enableNotifications = false
        viewModel.persistTimer()
        
        let retrieveViewModel = ParkingTimerViewModel.loadCurrentOrNew()
        
        XCTAssertEqual(viewModel.saveParkingLocation, retrieveViewModel.saveParkingLocation)
        XCTAssertEqual(viewModel.enableNotifications, retrieveViewModel.enableNotifications)
        
        if #available(iOS 15.0, *) {
            XCTAssertEqual(viewModel.endDate.formatted(.iso8601), retrieveViewModel.endDate.formatted(.iso8601))
        }
        
    }
    
    func testStart() {
        
        let viewModel = ParkingTimerViewModel()
        
        viewModel.carPosition = CLLocationCoordinate2D(latitude: 51, longitude: 26)
        viewModel.startTimer()
        
        XCTAssertEqual(viewModel.timerStarted, true)
        XCTAssertTrue(FileManager.default.fileExists(atPath: persistanceURL.path))
        
        let loaded = ParkingTimerViewModel.loadCurrentOrNew()
        XCTAssertEqual(loaded.carPosition?.latitude, 51)
        XCTAssertEqual(loaded.carPosition?.longitude, 26)
        
    }
    
}
