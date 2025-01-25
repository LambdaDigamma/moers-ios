//
//  TransitLocationRow.swift
//  
//
//  Created by Lennart Fischer on 10.12.21.
//

import SwiftUI
import EFAAPI

public struct TransitLocationRow: View {
    
    public var transitLocation: TransitLocation
    
    public init(transitLocation: TransitLocation) {
        self.transitLocation = transitLocation
    }
    
    public var body: some View {
        
        HStack(alignment: .top, spacing: 16) {
            
            ZStack {
                
                switch transitLocation.locationType {
                    case .singlehouse:
                        Image(systemName: "house.fill")
                            .resizable()
                            .scaledToFit()
                    case .location:
                        Image(systemName: "mappin.and.ellipse")
                            .resizable()
                            .scaledToFit()
                    case .stop:
                        Image(systemName: "h.circle.fill")
                            .resizable()
                            .scaledToFit()
                    case .street:
                        Image(systemName: "signpost.right.fill")
                            .resizable()
                            .scaledToFit()
                    default:
                        Image(systemName: "mappin.and.ellipse")
                            .resizable()
                            .scaledToFit()
                }
                
            }
            .foregroundColor(.secondary)
            .frame(width: 26)
            .padding(.top, 4)
            
            VStack(alignment: .leading, spacing: 2) {
                
                Text(transitLocation.name)
                    .foregroundColor(.primary)
                    .font(.headline.weight(.semibold))
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(transitLocation.description)
                    .font(.callout)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
            }
            
        }
        .padding(.vertical, 12)
        .padding(.horizontal)
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
}

struct TransitLocationRow_Previews: PreviewProvider {
    static var previews: some View {
        
        Button(action: {}) {
            TransitLocationRow(transitLocation: TransitLocation(
                locationType: .singlehouse,
                name: "Musterstraße",
                description: "Moers, 47441, Deutschland",
                coordinates: nil
            ))
        }
            .previewLayout(.sizeThatFits)
        
        TransitLocationRow(transitLocation: TransitLocation(
            locationType: .location,
            name: "Moers Rathaus",
            description: "",
            coordinates: nil
        ))
            .previewLayout(.sizeThatFits)
        
        TransitLocationRow(transitLocation: TransitLocation(
            locationType: .street,
            name: "Moers Rathaus",
            description: "",
            coordinates: nil
        ))
            .previewLayout(.sizeThatFits)
        
        TransitLocationRow(transitLocation: TransitLocation(
            locationType: .stop,
            name: "Moers Rathaus",
            description: "",
            coordinates: nil
        ))
            .previewLayout(.sizeThatFits)
    }
}
