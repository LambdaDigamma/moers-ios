//
//  SearchBar.swift
//  moers festival
//
//  Created by Lennart Fischer on 13.03.23.
//  Copyright © 2023 Code for Niederrhein. All rights reserved.
//

import SwiftUI

struct SearchBar: View {
    
    @Binding var text: String
    
    @State private var isEditing = false
    @FocusState private var isSearchFocused: Bool
    
    var body: some View {
        HStack(spacing: 10) {
            
            TextField("Orte suchen", text: $text)
                .focused($isSearchFocused)
                .padding(7)
                .padding(.horizontal, 25)
//                .background(Color(.systemGray6))
                .background(Color.tertiarySystemBackground)
                .cornerRadius(10)
                .overlay(
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.tertiaryLabel)
                            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                            .padding(.leading, 8)
                        
                        if isSearchFocused {
                            Button(action: {
                                self.text = ""
                            }) {
                                Image(systemName: "multiply.circle.fill")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 8)
                            }
                        }
                    }
                )
//                .padding(.horizontal, 10)
            
            if isSearchFocused {
                Button(action: {
                    self.isSearchFocused = false
                    self.text = ""
                    
                }) {
                    Text("Cancel")
                }
//                .padding(.trailing, 10)
                .transition(.move(edge: .trailing))
//                .animation(.default)
            }
        }
    }
}

struct SearchBar_Previews: PreviewProvider {
    
    static var previews: some View {
        
        SearchBar(text: .constant(""))
//            .padding()
            .previewLayout(.sizeThatFits)
        
    }
    
}
