//
//  SmallNewsFeedView.swift
//
//
//  Created by Lennart Fischer on 01.01.21.
//

import SwiftUI

public struct SmallNewsFeedView: View {
    
    public var body: some View {
        
        HStack(spacing: 12) {
            
            Image("mf-2019-15")
                .resizable()
                .frame(height: 70)
                .background(RoundedRectangle(cornerRadius: 12))
                .foregroundColor(Color.green)
            
                            //            alignment: Image("mf-2019-15")
//                .resizable()
////                .aspectRatio(1, contentMode: .fill)
//                .frame(height: 70, alignment: .leading)
//                .aspectRatio(CGSize(width: 50, height: 50), contentMode: .fill)
//                .cornerRadius(Margin.medium)
            
            VStack(alignment: .leading, spacing: 8) {
                
                Text("Lorem ipsum sed amor")
                    .font(.title)
                    .multilineTextAlignment(.leading)
                    .foregroundColor(.primary)
                
                Text("Zum 50. Mal fallen Tenor-Berserker, subversive Audio-Agitatorinnen, Elektro-Nerds, wütende Poetinnen...")
                    .multilineTextAlignment(.leading)
                    .font(.footnote)
                    .foregroundColor(.secondary)
                
            }
            
        }
        
    }
    
}

struct SmallNewsFeedView_Previews: PreviewProvider {
    static var previews: some View {
        SmallNewsFeedView()
    }
}
