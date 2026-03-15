//
//  BoothRow.swift
//  moers festival
//
//  Created by Lennart Fischer on 15.05.24.
//  Copyright © 2024 Code for Niederrhein. All rights reserved.
//

import SwiftUI

struct BoothRowUi: Hashable {
    
    var name: String
    var description: String
    var isFood: Bool
    
}

struct BoothRow: View {
    
    var booth: BoothRowUi
    
    var body: some View {
        
        HStack() {
            
            VStack(alignment: .leading, spacing: 4) {
                
                HStack(alignment: .top) {
                    
                    Text(booth.name)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                }
                
                Text(booth.description)
                    .lineLimit(1)
                    .foregroundColor(.secondary)
                
            }
            
            Spacer()
                .frame(maxWidth: 16)
            
            Image(systemName: "chevron.right")
                .foregroundColor(.secondary)
            
        }
        
    }
}

#Preview {
    BoothRow(booth: BoothRowUi(
        name: "Grillmeister",
        description: "Beschreibung", 
        isFood: true
    ))
}
