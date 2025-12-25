//
//  SwiftUIView.swift
//  
//
//  Created by Lennart Fischer on 03.04.22.
//

import SwiftUI

public struct NextStops: View {
    
    public struct StopEntry: Equatable, Hashable {
        public let name: String
        public let arrival: Date?
    }
    
    public let stops: [StopEntry] = [
        .init(name: "Düsseldorf", arrival: Date(timeIntervalSinceNow: 5 * 60)),
        .init(name: "Köln", arrival: Date(timeIntervalSinceNow: 25 * 60)),
        .init(name: "…", arrival: nil),
        .init(name: "Aachen", arrival: Date(timeIntervalSinceNow: 25 * 60)),
    ]
    
    public var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            
            ForEach(stops, id: \.self) { stop in
                
                HStack {
                    
                    Text(stop.name)
                        .fontWeight(.medium)
                        .padding(.leading, 20)
                        .padding(.vertical, 4)
                    
                    Spacer()
                    
                    if let arrival = stop.arrival {
                        
                        Text(arrival, style: .time)
                            .font(.callout)
                        
                    }
                    
                }
                .background(
                    ZStack(alignment: .center) {
                        
                        let color = Color(hex: "95969E")
                        
                        Rectangle()
                            .fill(color)
                            .frame(width: 2)
                        
                        Circle()
                            .fill(color)
                            .aspectRatio(1, contentMode: .fit)
                            .frame(width: 8)
                        
                    }.frame(maxWidth: .infinity, alignment: .leading)
                )
                
            }
            
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
}

struct NextStops_Previews: PreviewProvider {

    static var previews: some View {
        
        NextStops()
            .background(Color(UIColor.secondarySystemBackground))
            .cornerRadius(12)
            .padding()
            .previewLayout(.sizeThatFits)
        
    }

}
