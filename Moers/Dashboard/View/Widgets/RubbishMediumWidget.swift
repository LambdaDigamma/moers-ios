//
//  RubbishMediumWidget.swift
//  Moers
//
//  Created by Lennart Fischer on 06.03.21.
//  Copyright © 2021 Lennart Fischer. All rights reserved.
//

import SwiftUI
import WidgetKit

struct RubbishMediumWidget: View {
    
    // TODO: Vielleicht die vier Dinger wie Kalenderblätter? (mit Umrandung)
    var body: some View {
        ZStack {
            Color.systemBackground
            
            VStack(alignment: .leading) {
                Text("Adlerstraße")
                    .font(.title).fontWeight(.semibold)
                
                HStack {
                    
                    VStack {
                        
                        Image("paperWaste")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 80)
                        
                        Text("Morgen")
                            .font(.footnote)
                        
                    }
                    
                    VStack {
                        
                        Image("yellowWaste")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 80)
                        
                        Text("21.03.")
                            .font(.footnote)
                        
                    }
                    
                    VStack {
                        
                        Image("greenWaste")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 80)
                        
                        Text("24.03.")
                            .font(.footnote)
                        
                    }
                    
                    VStack {
                        
                        Image("residualWaste")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 80)
                        
                        Text("28.03.")
                            .font(.footnote)
                        
                    }
                    
                }.frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding()
            .frame(
                maxWidth: .infinity,
                maxHeight: .infinity,
                alignment: .topLeading
            )
            
        }
        
    }
    
}

struct RubbishMediumWidget_Previews: PreviewProvider {
    static var previews: some View {
        
        let widget = RubbishMediumWidget()
            .previewLayout(.fixed(width: 360, height: 169))
            
        return Group {
            widget
            widget.environment(\.colorScheme, .dark)
            
        }
        
    }
}
