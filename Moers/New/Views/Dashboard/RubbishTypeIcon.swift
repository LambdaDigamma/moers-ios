//
//  RubbishTypeIcon.swift
//  Moers
//
//  Created by Lennart Fischer on 19.08.21.
//  Copyright © 2021 Lennart Fischer. All rights reserved.
//

import SwiftUI
import MMAPI
import ModernNetworking

public struct RubbishTypeIcon: View {
    
    public var type: RubbishWasteType
    
    public init(type: RubbishWasteType) {
        self.type = type
    }
    
    public var body: some View {
        
        ZStack {
            switch type {
                
                case .organic:
                    Image("greenWaste")
                        .resizable()
                case .residual:
                    Image("residualWaste")
                        .resizable()
                case .paper:
                    Image("paperWaste")
                        .resizable()
                case .cuttings:
                    Image("greenWaste")
                        .resizable()
                case .plastic:
                    Image("yellowWaste")
                        .resizable()
            }
        }
        .aspectRatio(1, contentMode: .fit)
        
    }
    
}

struct RubbishTypeIcon_Previews: PreviewProvider {
    static var previews: some View {
        RubbishTypeIcon(type: .organic)
            .frame(width: 50)
            .padding()
            .previewLayout(.sizeThatFits)
    }
}
