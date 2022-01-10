//
//  SmallParkingDashboarding.swift
//  
//
//  Created by Lennart Fischer on 10.01.22.
//

import SwiftUI

struct SmallParkingDashboard: View {
    
    private let total: Int = 140
    private let free: Int = 26
    
    private var freePercent: Double {
        return 1 - Double(free) / Double(total)
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 4) {
            
            HStack {
                
                Text("Kastellplatz")
                    .font(.title3.weight(.semibold))
                
                Spacer()
                
                Text("Geöffnet")
                    .font(.caption.weight(.semibold))
                    .padding(8)
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(8)
                
            }
            
            VStack(alignment: .leading) {
                
                Text("\(free)")
                    .font(.largeTitle.weight(.bold))
                
                Text("frei")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
            }
            .padding(.bottom, 8)
            
            VStack(alignment: .leading) {
                
                ProgressMeterView(value: freePercent)
                
                
                Text("Gesamt: \(total)")
                    .font(.caption)
                    .foregroundColor(.secondary)
                
            }
            
        }
        .padding()
        
    }
    
    
    
}

struct SmallParkingDashboarding_Previews: PreviewProvider {
    static var previews: some View {
        
        SmallParkingDashboard()
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
        
        SmallParkingDashboard()
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
            .frame(maxWidth: 200)
        
    }
}
