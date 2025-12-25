//
//  ProgressTourCardView.swift.swift
//
//
//  Created by Lennart Fischer on 16.12.20.
//

import SwiftUI
import MMCommon

public struct ProgressTourCardView: View {
    
    @State private var downloadAmount = 10.0
    
    public init() {
        
    }
    
    public var body: some View {
        
        HStack(alignment: .center, spacing: 20) {
            
            ProgressView(value: downloadAmount, total: 50.0)
                .progressViewStyle(CircleSteppedPercentageProgressViewStyle(total: 50))
                .frame(width: 74, height: 74, alignment: .center)
                .accentColor(.green)
            
            
            VStack(alignment: .leading, spacing: 16) {
                (Text("Dein Fortschritt ") + Text(Image(systemName: "chevron.right").resizable()))
                    .font(.title)
                Text("Du hast schon 5 Ausstellungsorte besucht. Einige stehen noch aus. Setze Deine Tour fort und finde alle Ausstellungsorte!")
                    .font(.footnote)
                    .foregroundColor(Color(.secondaryLabel))
            }
            
        }
        .padding(20)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        
    }
    
}

struct ProgressTourCardView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        NavigationView {
            ProgressTourCardView()
                .padding(20)
                .navigationBarTitle("Ausstellung")
        }
        .environment(\.colorScheme, .dark)
        .environment(\.sizeCategory, .extraSmall)
        
    }
    
}
