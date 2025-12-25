//
//  DownloadTourView.swift
//  
//
//  Created by Lennart Fischer on 16.12.20.
//

import SwiftUI
import MMCommon

struct DownloadTourView: View {
    
    var body: some View {
        
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 16) {
                Text("Inhalte herunterladen")
                    .font(.title)
                Text("Wir empfehlen Dir, alle Inhalte schon jetzt herunterzuladen, damit vor Ort nicht Dein mobiles Datenvolumen verwendet wird.")
                    .font(.footnote)
                    .foregroundColor(Color(.secondaryLabel))
            }
            Spacer()
            VStack(spacing: 8) {
                
                Button(action: {}, label: {
                    Text("Laden")
                        .textCase(.uppercase)
                        .font(.system(size: 12, weight: .bold, design: .default))
                        .foregroundColor(Color.primary)
                        .padding(.vertical, 16)
                        .padding(.horizontal, 20)
                        .background(Color(.tertiarySystemBackground))
                        .cornerRadius(20)
                })
                
                HStack(alignment: .firstTextBaseline, spacing: 8) {
                    Image(systemName: "square.and.arrow.down")
                        .font(.system(size: 10, weight: .medium, design: .default))
                    Text("53,6 MB")
                        .font(.system(size: 8, weight: .medium, design: .default))
                }
                .foregroundColor(Color(.secondaryLabel))
                
            }
            
        }
        .padding(20)
        .background(Color(.secondarySystemBackground))
        .cornerRadius(12)
        
    }
    
}

struct DownloadTourView_Previews: PreviewProvider {
    static var previews: some View {
        
        NavigationView {
            DownloadTourView()
                .padding(20)
                .navigationBarTitle("Ausstellung")
        }.environment(\.colorScheme, .dark)
        
    }
}
