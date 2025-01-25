//
//  FootPathView.swift
//  
//
//  Created by Lennart Fischer on 09.04.22.
//

import SwiftUI

public struct FootPathView: View {
    
    public let name: String
    public let time: Date
    public let durationInMinutes: Int
    public let distance: Int?
    
    public var body: some View {
        
        HStack(alignment: .top) {
            
            Text(time, style: .time)
                .font(.body.weight(.semibold))
            
            VStack(alignment: .leading, spacing: 4) {
                
                Text(name)
                    .fontWeight(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
                    
                    Image(systemName: "figure.walk")
                    
                    if let distance = distance {
                        Text("\(durationInMinutes) Minuten (\(distance)m), Fußweg")
                    } else {
                        Text("\(durationInMinutes) Minuten, Fußweg")
                    }
                    
                }
                .foregroundColor(.secondary)
                
            }
            
        }
        .padding()
        
    }
    
}


struct FootPathView_Previews: PreviewProvider {
    static var previews: some View {
        FootPathView(
            name: "Musterstraße 10, 12345 Musterstadt",
            time: Date(timeIntervalSinceNow: 60 * 60),
            durationInMinutes: 7,
            distance: 856
        )
        .previewLayout(.sizeThatFits)
        
        FootPathView(
            name: "Musterstraße 10, 12345 Musterstadt",
            time: Date(timeIntervalSinceNow: 60 * 60),
            durationInMinutes: 7,
            distance: 856
        )
        .previewLayout(.sizeThatFits)
        .preferredColorScheme(.dark)
    }
}
