//
//  RubbishScheduleList.swift
//  
//
//  Created by Lennart Fischer on 15.12.21.
//

import SwiftUI

public struct RubbishScheduleList: View {
    
    private let items: [RubbishPickupItem]
    
    public init() {
        self.items = [
            .init(date: .init(timeIntervalSinceNow: TimeInterval(4 * 24 * 60 * 60)), type: .residual),
            .init(date: .init(timeIntervalSinceNow: TimeInterval(8 * 24 * 60 * 60)), type: .organic),
            .init(date: .init(timeIntervalSinceNow: TimeInterval(9 * 24 * 60 * 60)), type: .paper),
            .init(date: .init(timeIntervalSinceNow: TimeInterval(12 * 24 * 60 * 60)), type: .plastic),
        ]
    }
    
    public var body: some View {
        
        List {
            
            Section(header: Text("March 2022")) {
                ForEach(items) { item in
                    RubbishPickupRow(item: item)
                }
            }
            
            Section(header: Text("April 2022")) {
                ForEach(items) { item in
                    RubbishPickupRow(item: item)
                }
            }
            
        }
        
    }
    
}

struct RubbishScheduleList_Previews: PreviewProvider {
    static var previews: some View {
        
        NavigationView {
            
            RubbishScheduleList()
            
        }
        
    }
}
