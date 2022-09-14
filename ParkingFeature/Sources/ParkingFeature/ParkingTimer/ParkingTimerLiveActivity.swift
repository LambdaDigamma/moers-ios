//
//  ParkingTimerLiveActivity.swift
//  
//
//  Created by Lennart Fischer on 13.09.22.
//

import Foundation
import ActivityKit

public struct ParkingTimerAttributes: ActivityAttributes {
    
    public typealias ParkingTimerState = ContentState
    
    public init() {
        
    }
    
    public struct ContentState: Codable, Hashable {
        public init(endTime: Date) {
            self.endTime = endTime
        }
        
        public var endTime: Date
    }
    
}


@available(iOS 16.0, *)
class ParkingTimerLiveActivity {
    
    var statusActivity: Activity<ParkingTimerAttributes>?
    
    func start(date: Date) {
        
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("Activities are not enabled!")
            return
        }
        
        let statusAttribute = ParkingTimerAttributes()
        let initialStatus = ParkingTimerAttributes.ContentState(
            endTime: date
        )
        
        do {
            statusActivity = try Activity<ParkingTimerAttributes>.request(
                attributes: statusAttribute,
                contentState: initialStatus,
                pushType: nil
            )
            
            guard let statusActivity else {
                print("Error: Could not initialize activity.")
                return
            }
            
        } catch (let error) {
            print("Error: \(error.localizedDescription)")
        }
        
    }
    
    // Now I will update the current activity.
    func update() {
//        Task {
//            let updatedCICDStatus = StatusAttribute.ProcessStatus(status: .inProgress,
//                                                                  estimatedCompletionTime: Date().addingTimeInterval(30))
//            guard let statusActivity else {
//                return
//            }
//
//            await statusActivity.update(using: updatedCICDStatus)
//        }
    }
    
    func end() {
//        Task {
//            let updatedCICDStatus = StatusAttribute.ProcessStatus(status: status, estimatedCompletionTime: Date())
//
//            guard let statusActivity else {
//                return
//            }
//
//            await statusActivity.end(using: updatedCICDStatus, dismissalPolicy: .default)
//        }
    }
    
}
