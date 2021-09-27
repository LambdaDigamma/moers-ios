//
//  BroadcastRow.swift
//  
//
//  Created by Lennart Fischer on 25.09.21.
//

import SwiftUI
import Nuke
import NukeUI

public struct BroadcastRow: View {
    
    public let title: String
    public let imageURL: String?
    
    public let startDate: Date?
    public let endDate: Date?
    
    public var body: some View {
        
        HStack(alignment: .top, spacing: 12) {
            
            ZStack {
                
                if let imageURL = imageURL {
                    LazyImage(source: imageURL)
                        .processors([ImageProcessors.Resize(width: 44)])
                        .cornerRadius(8)
                } else {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(UIColor.tertiarySystemFill))
                        .aspectRatio(1, contentMode: .fit)
                        .frame(maxWidth: 44, maxHeight: 44)
                }
                
            }
            .frame(maxWidth: 44, maxHeight: 44)
            
            VStack(alignment: .leading, spacing: 4) {
                
                Text(title)
                    .foregroundColor(.primary)
                    .font(.callout)
                    .fontWeight(.semibold)
                    .multilineTextAlignment(.leading)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            Image(systemName: "chevron.forward")
                .font(.body.weight(.semibold))
                .foregroundColor(Color(UIColor.tertiaryLabel))
                .padding(.vertical)
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
    var subtitle: String {
        
        if let startDate = startDate, let endDate = endDate {
            return Self.intervalFormatter.string(from: startDate, to: endDate)
        } else {
            return "Uhrzeit nicht bekannt"
        }
        
    }
    
    static let intervalFormatter: DateIntervalFormatter = {
        
        let formatter = DateIntervalFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        
        return formatter
        
    }()
    
}

public struct BroadcastRow_Preview: PreviewProvider {
    
    public static var previews: some View {
        BroadcastRow(
            title: "Landeskirchschicht in Kamp-Lintfort",
            imageURL: nil,
            startDate: Date(),
            endDate: Date(timeIntervalSinceNow: 60 * 60)
        )
            .padding()
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
    }
    
}
