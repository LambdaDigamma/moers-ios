//
//  ParkingTimerActivityView.swift
//  WidgetsExtension
//
//  Created by Lennart Fischer on 13.09.22.
//  Copyright © 2022 Lennart Fischer. All rights reserved.
//

import ActivityKit
import SwiftUI
import WidgetKit

@available(iOS 16.0, *)
@available(iOSApplicationExtension 16.0, *)
struct ParkingTimerActivityView: View {
    
    @State var attribute: ParkingTimerAttributes
    @State var state: ParkingTimerAttributes.ContentState
    
    var body: some View {
        
        VStack(alignment: .leading) {
            
            Text("Übrige Parkzeit")
            
            Text(state.endTime, style: .timer)
                .monospacedDigit()
                .font(.largeTitle)
//                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding()
        .frame(height: 220)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.blue)
        .activityBackgroundTint(Color.blue)
        
    }
    
}

@available(iOS 16.0, *)
@available(iOSApplicationExtension 16.0, *)
struct ParkingTimerActivityView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        let testAttribute = ParkingTimerAttributes()
        let testState = ParkingTimerAttributes.ContentState(
            endTime: Date(timeIntervalSinceNow: 60 * 60 * 3)
        )
        
        ParkingTimerActivityView(
            attribute: testAttribute,
            state: testState
        )
        .previewLayout(.sizeThatFits)
//        .previewContext(
//            WidgetPreviewContext(
//                family: .systemLarge
//            )
//        )
        
    }
    
}
