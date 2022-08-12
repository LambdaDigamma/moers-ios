//
//  RubbishAccessoryInline.swift
//  Moers
//
//  Created by Lennart Fischer on 08.06.22.
//  Copyright © 2022 Lennart Fischer. All rights reserved.
//

import SwiftUI
import WidgetKit
import RubbishFeature

struct RubbishAccessoryInline: View {
    
    public let items: [RubbishPickupItem]
    
    public init(items: [RubbishPickupItem]) {
        self.items = items
    }
    
    var body: some View {
        let sections = items
            .groupByDayIntoSections()
        
        if let section = sections.first {
            
            
            let shortNames = section.items
                .map({ $0.type.shortName })
            
            let items = ListFormatter
                .localizedString(byJoining: shortNames)
            
            Text(items)
            
//            HStack {
//
//                VStack(alignment: .leading) {
//
//
//
//                }
//                .frame(maxWidth: .infinity, alignment: .leading)
//
//            }
            
        }
    }
    
}

struct RubbishAccessoryInline_Previews: PreviewProvider {
    static var previews: some View {
        RubbishAccessoryInline(items: RubbishPickupItem.placeholder)
//            .previewContext(WidgetPreviewContext(family: .accessoryInline))
    }
}
