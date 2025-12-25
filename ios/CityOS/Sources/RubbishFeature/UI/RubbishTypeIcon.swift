//
//  RubbishTypeIcon.swift
//  Moers
//
//  Created by Lennart Fischer on 19.08.21.
//  Copyright © 2021 Lennart Fischer. All rights reserved.
//

import SwiftUI
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
                    Image("greenWaste", bundle: .module)
                        .resizable()
                case .residual:
                    Image("residualWaste", bundle: .module)
                        .resizable()
                case .paper:
                    Image("paperWaste", bundle: .module)
                        .resizable()
                case .cuttings:
                    Image("greenWaste", bundle: .module)
                        .resizable()
                case .plastic:
                    Image("yellowWaste", bundle: .module)
                        .resizable()
                    
            }
        }
        .aspectRatio(1, contentMode: .fit)
        
    }
    
}

struct RubbishTypeIcon_Previews: PreviewProvider {
    static var previews: some View {
        
        ForEach(RubbishWasteType.allCases, id: \.self) { type in
            RubbishTypeIcon(type: type)
                .frame(width: 50)
                .padding()
                .previewLayout(.sizeThatFits)
        }
        
    }
}
