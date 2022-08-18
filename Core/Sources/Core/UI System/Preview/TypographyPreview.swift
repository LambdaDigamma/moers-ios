//
//  TypographyPreviewView.swift
//  
//
//  Created by Lennart Fischer on 16.12.20.
//

import SwiftUI

struct TypographyPreviewView: View {
    var body: some View {
        
        VStack(alignment: .leading, spacing: 16) {
            
            Group {
                
//                Text("Title Extra Large")
//                    .font(.style(.titleExtraLarge))
//
//                Text("Title Large")
//                    .font(.style(.titleLarge))
//
//                Text("Subtitle Large")
//                    .font(.style(.subtitleLarge))
//
//                Text("Title")
//                    .font(.style(.title))
//
//                Text("Subtitle")
//                    .font(.style(.subtitle))
//
//                Text("Headline")
//                    .font(.style(.headline))
//
//                Text("Body")
//                    .font(.style(.body))
                
            }
            
            Group {
                
//                Text("Headline Small")
//                    .font(Font.style(.headlineSmall))
//
//                Text("Body Small")
//                    .font(Font.style(.body))
//
//                Text("Caption")
//                    .font(Font.style(.caption))
//
//                Text("Footnote")
//                    .font(Font.style(.footnote))
                
            }
            
        }
        
        
    }
}

struct TypographyPreviewView_Previews: PreviewProvider {
    static var previews: some View {
        
        Group {
            
            TypographyPreviewView()
            
            TypographyPreviewView()
                .environment(\.sizeCategory, .accessibilityExtraExtraLarge)
            
        }
        
        
    }
}
