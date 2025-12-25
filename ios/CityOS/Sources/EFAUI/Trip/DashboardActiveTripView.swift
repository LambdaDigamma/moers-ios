//
//  DashboardActiveTripView.swift
//  
//
//  Created by Lennart Fischer on 15.12.22.
//

import SwiftUI

public struct DashboardActiveTripView: View {
    
    public init() {
        
    }
    
    public var body: some View {
        Text("Trip is configured")
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color.yellow)
            .cornerRadius(16)
    }
    
}

struct DashboardActiveTripView_Previews: PreviewProvider {
    static var previews: some View {
        DashboardActiveTripView()
            .preferredColorScheme(.dark)
            .previewLayout(.sizeThatFits)
    }
}
