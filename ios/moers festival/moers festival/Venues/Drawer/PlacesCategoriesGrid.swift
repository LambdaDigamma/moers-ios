//
//  PlacesCategoriesGrid.swift
//  moers festival
//
//  Created by Lennart Fischer on 13.03.23.
//  Copyright © 2023 Code for Niederrhein. All rights reserved.
//

import SwiftUI

struct PlaceCategory: Identifiable {
    
    var id: Int
    var text: String
    var color: Color
    var image: Image? = nil
    var foregroundColor: Color = .white
    
}

struct PlacesCategoriesGrid: View {
    
    var categories: [PlaceCategory] = [
        .init(
            id: 1,
            text: "Bühnen",
            color: .black,
            image: Image(systemName: "music.mic")
        ),
        .init(
            id: 2,
            text: "Toiletten",
            color: .blue,
            image: Image(systemName: "figure.dress.line.vertical.figure")
        ),
        .init(
            id: 3,
            text: "Stände",
            color: .gray,
            image: Image(systemName: "bag.fill")
        ),
        .init(
            id: 4,
            text: "Erste Hilfe",
            color: .green,
            image: Image(systemName: "cross.fill")
        ),
        .init(
            id: 5,
            text: "Fahrräder",
            color: .orange,
            image: Image(systemName: "bicycle")
        )
    ]
    
    var body: some View {
        
        ScrollView(.horizontal, showsIndicators: false) {
            
            HStack(spacing: 16) {
                
                ForEach(categories) { (category: PlaceCategory) in
                    
                    VStack(alignment: .center, spacing: 8) {
                        Circle()
                            .fill(category.color)
                            .frame(width: 60, height: 60, alignment: .center)
                            .overlay(alignment: .center) {
                                if let image = category.image {
                                    image.resizable()
                                        .scaledToFit()
                                        .padding()
                                }
                            }
                        
                        Text(category.text)
                            .font(.footnote)
//                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: 70)
                    
                }
                
            }
            .padding(16)
            
        }
        
    }
    
}

struct PlacesCategoriesGrid_Previews: PreviewProvider {
    static var previews: some View {
        PlacesCategoriesGrid()
            .background(Color.tertiarySystemBackground)
    }
}
