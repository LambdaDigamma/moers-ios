//
//  FestivalMapView.swift
//  moers festival
//
//  Created by Lennart Fischer on 12.03.23.
//  Copyright © 2023 Code for Niederrhein. All rights reserved.
//

import SwiftUI
import MMEvents

struct FestivalDrawerScreen: View {
    
    @ObservedObject private var viewModel: FestivalMapViewModel
    
    private let onShowPlace: (Place.ID) -> Void
    
    init(viewModel: FestivalMapViewModel, onShowPlace: @escaping (Place.ID) -> Void) {
        self.viewModel = viewModel
        self.onShowPlace = onShowPlace
    }
    
    var body: some View {
        
        FestivalDrawerView(
            data: .init(places: viewModel.places),
            refresh: {
                viewModel.refresh()
            }, onShowPlace: { (placeID: Place.ID) in
                onShowPlace(placeID)
            }
        )
        .task {
            viewModel.load()
        }
        
    }
    
}

struct FestivalDrawerData {
    
    let places: [FestivalPlaceRowUi]
    
}

struct FestivalDrawerView: View {
    
    var data: FestivalDrawerData
    
    var refresh: () -> ()
    
    var onShowPlace: (Place.ID) -> Void
    
    @State var search: String = ""
    
    var body: some View {
        
        VStack(spacing: 0) {
            
            stickyHeader()
            
            ScrollView {
                
                LazyVStack(spacing: 28) {
                    
//                    categoriesSection()
                    
                    venuesSection()
                    
                }
                .padding(.top, 16)
                .padding(.bottom, 48)
                
            }
            .searchable(text: $search)
            .refreshable {
                refresh()
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        
    }
    
    @ViewBuilder
    private func categoriesSection() -> some View {
        
        VStack(alignment: .leading, spacing: 8) {
            
            HStack {
                Text("Kategorien")
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
            }
            .font(.callout)
            .padding(.horizontal)
            
            ScrollView(.horizontal, showsIndicators: false) {
                
                PlacesCategoriesGrid()
                    .background(Color.tertiarySystemBackground)
                    .cornerRadius(10)
                    .padding(.horizontal)
                
            }
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
    @ViewBuilder
    private func venuesSection() -> some View {
        
        VStack(alignment: .leading, spacing: 8) {
            
            HStack {
                Text("Stages")
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
            }
            .font(.callout)
            .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 0) {
                
                ForEach(data.places) { (place: FestivalPlaceRowUi) in
                    
                    Button(action: {
                        onShowPlace(place.id)
                    }) {
                        FestivalPlaceRow(place: place)
                            .padding(.horizontal)
                            .padding(.vertical)
                    }
                    
                }
                
            }
            .background(Color.tertiarySystemBackground)
            .cornerRadius(10)
            .padding(.horizontal)
            
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        
    }
    
    @ViewBuilder
    private func stickyHeader() -> some View {
        
        VStack(spacing: 0) {
            
            SearchBar(text: $search)
                .padding(.horizontal)
                .padding(.vertical)
            
        }
        .frame(height: 56)
        .overlay(alignment: .bottom) {
            Divider()
        }
        .overlay(alignment: .top) {
            Rectangle()
                .fill(Color.secondary)
                .frame(width: 36, height: 5)
                .cornerRadius(2.5)
                .padding(.top, 6)
                .padding(.bottom, 6)
        }
        
    }
    
}

struct FestivalDrawerView_Previews: PreviewProvider {
    static var previews: some View {
        FestivalDrawerView(
            data: .init(places: []),
            refresh: {}, onShowPlace: { _ in
                
            }
        )
        .previewLayout(.sizeThatFits)
    }
}
