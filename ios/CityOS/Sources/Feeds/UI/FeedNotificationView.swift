//
//  FeedNotificationView.swift
//
//
//  Created by Lennart Fischer on 01.01.21.
//

import SwiftUI

public struct FeedNotificationView: View {
    
    
    public var body: some View {
        
        VStack(alignment: .leading, spacing: 16) {
            
            Text("Verlegung des Konzerts xyz")
                .foregroundColor(Color.black)
                .font(.title)
            
            Text("Aufgrund des Wetters findet das Konzert [...] nicht auf der Parkbühe statt, sondern wird ins Moerser Schloss verlegt. Was auch immer hier noch steht...")
                .foregroundColor(Color.black)
                .multilineTextAlignment(.leading)
                .font(.footnote)
            
        }
        .padding(20)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.yellow)
        .cornerRadius(12)
        
    }
    
}

struct FeedNotificationView_Previews: PreviewProvider {
    static var previews: some View {
        FeedNotificationView()
    }
}
