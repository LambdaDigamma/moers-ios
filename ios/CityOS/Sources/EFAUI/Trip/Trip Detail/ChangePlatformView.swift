//
//  ChangePlatformView.swift
//  
//
//  Created by Lennart Fischer on 09.04.22.
//

import SwiftUI

public struct ChangePlatformView: View {
    
    public var body: some View {
        
        Text("\(Image(systemName: "point.topleft.down.curvedto.point.bottomright.up")) Gleis wechseln")
            .foregroundColor(.secondary)
            .font(.footnote)
            .frame(maxWidth: .infinity, alignment: .center)
            .padding()
    }
    
}

struct ChangePlatformView_Previews: PreviewProvider {
    static var previews: some View {
        ChangePlatformView()
            .previewLayout(.sizeThatFits)
        
        ChangePlatformView()
            .previewLayout(.sizeThatFits)
            .preferredColorScheme(.dark)
    }
}
