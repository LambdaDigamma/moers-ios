//
//  EmergencyCard.swift
//  
//
//  Created by Lennart Fischer on 11.01.22.
//

import SwiftUI

public struct EmergencyCard: View {
    
    private let text: String
    private let foregroundColor: Color = .white
    private let backgroundColor: Color = .red
    
    public init(text: String) {
        self.text = text
    }
    
    public var body: some View {
        
        VStack(alignment: .leading, spacing: 8) {
            
            Text("Achtung!")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(foregroundColor)
            
            Text(text)
                .fontWeight(.semibold)
                .foregroundColor(foregroundColor)
                .multilineTextAlignment(.leading)
                .padding(.leading)
                .background(ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(foregroundColor)
                        .frame(width: 3)
                        .layoutPriority(2)
                }
                .frame(maxWidth: 200, alignment: .leading))
            
            Image(systemName: "chevron.forward.square.fill")
                .font(.title)
                .foregroundColor(foregroundColor)
                .padding(.top, 4)
            
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(ZStack {
            
            Image(systemName: "exclamationmark.triangle")
                .resizable()
                .scaledToFit()
                .offset(x: 0, y: 14)
                .opacity(0.2)
                .frame(maxHeight: 100)
            
        }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing))
        .background(backgroundColor)
        
    }
    
}

struct EmergencyCard_Previews: PreviewProvider {
    static var previews: some View {
        EmergencyCard(text: "Bombenentschärfung in Moers-Meerbusch")
            .previewLayout(.sizeThatFits)
    }
}
