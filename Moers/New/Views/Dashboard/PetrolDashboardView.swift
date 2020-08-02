//
//  PetrolDashboardView.swift
//  Moers
//
//  Created by Lennart Fischer on 27.06.20.
//  Copyright © 2020 Lennart Fischer. All rights reserved.
//

import SwiftUI
import MMAPI

@available(iOS 13.0, *)
struct PetrolDashboardView: View {
    
    var rubbishItems: [RubbishPickupItem] = []
    
    init(rubbishItems: [RubbishPickupItem] = []) {
        self.rubbishItems = Array(rubbishItems.prefix(3))
    }
    
    var body: some View {
        CardPanelView {
            
            VStack(alignment: .leading, spacing: 0) {
                
                HStack {
                    Text("Next emptyings")
                        .font(.title)
                        .fontWeight(.semibold)
                    Spacer()
                }
                .padding(.top)
                .padding(.horizontal)
                
                if rubbishItems.count != 0 {
                    
                    ForEach(rubbishItems, id: \.id) { (item) in
                        
                        HStack(alignment: .center) {
                            
                            switch item.type {
                                case .organic:
                                    Image("greenWaste")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                case .residual:
                                    Image("residualWaste")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                case .paper:
                                    Image("paperWaste")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                case .cuttings:
                                    Image("greenWaste")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                case .plastic:
                                    Image("yellowWaste")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                            }
                            
                            VStack(alignment: .leading) {
                                Text(RubbishWasteType.localizedForCase(item.type))
                                    .font(.headline)
                                    .fontWeight(.semibold)
                                    .padding(.bottom, 4)
                                Text("Mi. 01.07.2020")
                                    .font(.callout)
                            }
                            
                        }
                        .padding(.all, 12)
                        
                    }
                    
                } else {
                    
                    VStack {
                        HStack(spacing: 12) {
                            Image(systemName: "calendar.badge.exclamationmark").font(.largeTitle)
                            Text("There are no other known collection dates.")
                        }
                    }
                    .padding(.top, 8)
                    .padding(.horizontal)
                    .padding(.bottom)
                    
                    
                }
                
            }
            
        }
        .padding()
    }
}

@available(iOS 13.0, *)
struct PetrolDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        PetrolDashboardView()
    }
}
