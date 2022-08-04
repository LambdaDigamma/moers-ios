//
//  RubbishAccessoryRectangle.swift
//  Moers
//
//  Created by Lennart Fischer on 08.06.22.
//  Copyright © 2022 Lennart Fischer. All rights reserved.
//

import SwiftUI
import WidgetKit
import RubbishFeature

public struct RubbishAccessoryRectangle: View {
    
    public let items: [RubbishPickupItem]
    
    public init(items: [RubbishPickupItem]) {
        self.items = items
    }
    
    public var body: some View {
        
        let sections = items
            .groupByDayIntoSections()
        
        if let section = sections.first {
            
            
            let shortNames = section.items
                .map({ $0.type.shortName })
            
            let items = ListFormatter
                .localizedString(byJoining: shortNames)
            
            HStack {
                
                VStack(alignment: .leading) {
                    
                    Text("Pick-up \(section.header)")
                        .font(.headline)
                    
                    Text(items)
                    
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
            }
                
        }
        
    }
    
}

struct RubbishAccessoryRectangle_Previews: PreviewProvider {
    static var previews: some View {
        RubbishAccessoryRectangle(items: RubbishPickupItem.placeholder)
            .previewContext(WidgetPreviewContext(family: .accessoryRectangular))
    }
}
