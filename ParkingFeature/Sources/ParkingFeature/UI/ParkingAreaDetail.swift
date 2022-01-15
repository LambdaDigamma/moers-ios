//
//  ParkingAreaDetail.swift
//  
//
//  Created by Lennart Fischer on 10.01.22.
//

import Core
import SwiftUI

public struct ParkingAreaDetail: View {
    
    private let name: String
    private let total: Int
    private let free: Int
    
    private var freePercent: Double {
        return 1 - Double(free) / Double(total)
    }
    
    public init(viewModel: ParkingAreaViewModel) {
        self.name = viewModel.title
        self.free = viewModel.free
        self.total = viewModel.total
    }
    
    public init(name: String, total: Int, free: Int) {
        self.name = name
        self.free = free
        self.total = total
    }
    
    public var body: some View {
        
        VStack(alignment: .leading, spacing: 4) {
            
            HStack {
                
                Text(name)
                    .font(.title3.weight(.semibold))
                
                Spacer()
                
//                Text("Geöffnet")
//                    .font(.caption.weight(.semibold))
//                    .padding(8)
//                    .background(Color.green)
//                    .foregroundColor(.white)
//                    .cornerRadius(8)
                
            }
            
            VStack(alignment: .leading) {
                
                HStack(alignment: .firstTextBaseline) {
                    
                    Text("\(free)")
                        .font(.largeTitle.weight(.bold))
//                        .foregroundColor(.green)
                    
                    Text("/ \(total)")
                        .font(.headline)
                        .foregroundColor(.secondary)
                    
                }
                
                Text("frei")
                    .font(.headline)
                    .foregroundColor(.secondary)
                
            }
            .padding(.bottom, 8)
            
            VStack(alignment: .leading) {
                
                ProgressMeterView(
                    value: freePercent,
                    color: .gray
                )
                
                Text(Date(timeIntervalSinceNow: -2 * 60), style: .relative)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
            }
            
        }
        .padding()
        
    }
    
}

struct SmallParkingDashboarding_Previews: PreviewProvider {
    static var previews: some View {
        
        ParkingAreaDetail(name: "Kastell", total: 100, free: 34)
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
        
        ParkingAreaDetail(name: "Kastell", total: 100, free: 34)
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
            .redacted(reason: .placeholder)
        
        ParkingAreaDetail(name: "Kastell", total: 100, free: 34)
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
            .frame(maxWidth: 200)
        
    }
}
