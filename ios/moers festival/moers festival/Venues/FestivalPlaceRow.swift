//
//  FestivalPlaceRow.swift
//  moers festival
//
//  Created by Lennart Fischer on 12.03.23.
//  Copyright © 2023 Code for Niederrhein. All rights reserved.
//

import SwiftUI
import MMEvents

struct FestivalPlaceRowUi: Identifiable, Hashable {
    
    let id: Int
    let name: String
    let description: String
    let timeInformation: TimeInformation?
    
    enum TimeInformation: Hashable, Equatable {
        case live
        case date(Date)
    }
    
}

struct FestivalPlaceRow: View {
    
    let place: FestivalPlaceRowUi
    
    var body: some View {
        
        HStack() {
            
            VStack(alignment: .leading, spacing: 4) {
                
                HStack(alignment: .top) {
                    
                    Text(place.name)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Spacer()
                    
                    if let timeInformation = place.timeInformation {
                        
                        switch timeInformation {
                            case .date(let date):
                                UpcomingBadge(date: date)
                            case .live:
                                LiveBadge()
                        }
                        
                    }
                    
                }
                
                Text(place.description)
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

struct FestivalPlaceRow_Previews: PreviewProvider {
    static var previews: some View {
        
        let place = FestivalPlaceRowUi(
            id: 1,
            name: "ENNI Eventhalle",
            description: "Kenny Garrett and Sounds From The Ancestors",
            timeInformation: .live
        )
        
        FestivalPlaceRow(place: place)
            .previewLayout(.sizeThatFits)
    }
}
