//
//  StationListCardView.swift
//  
//
//  Created by Lennart Fischer on 01.01.21.
//

import SwiftUI
import MMCommon

public struct StationListCardView: View {
    
    public init() {
        
    }
    
    @State var airplaneMode = true
    
    public var body: some View {
        
        LazyVStack(spacing: 0) {
            
            ForEach(0..<10) { d in
                
                Toggle(isOn: $airplaneMode) {
                    Text("Das ist ein Test")
                }
                .toggleStyle(CheckboxStyle())
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding()
                
//                HStack {
////                    CheckboxView()
////                    Text("Das ist ein Test")
//                }
//                .frame(maxWidth: .infinity, alignment: .leading)
//                .padding()
                
                Divider()
            }
            
        }
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        
//        List {
//            Text("Das ist ein Test")
//            Text("Das ist ein Test")
//        }
//        .listStyle(InsetGroupedListStyle())
    }
}

struct StationListCardView_Previews: PreviewProvider {
    static var previews: some View {
        StationListCardView()
    }
}
