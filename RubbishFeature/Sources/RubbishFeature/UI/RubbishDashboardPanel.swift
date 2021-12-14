//
//  RubbishDashboardView.swift
//  Moers
//
//  Created by Lennart Fischer on 27.06.20.
//  Copyright © 2020 Lennart Fischer. All rights reserved.
//

import SwiftUI
import ModernNetworking
//import Core

public struct RubbishDashboardPanel: View {
    
    public var items: UIResource<[RubbishPickupItem]>
    
    public init(items: UIResource<[RubbishPickupItem]> = .loading) {
        self.items = items
    }
    
    public var body: some View {
        
        CardPanelView {
            
            VStack(alignment: .leading, spacing: 0) {
                
                items.isLoading {
                    loading()
                }
                
                items.hasResource { (items) in
                    
                    HStack {
                        Text(PackageStrings.Waste.dashboardTitle)
                            .font(.title2)
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    .padding(.top)
                    .padding(.horizontal, 20)
                    
                    if !items.isEmpty {
                        
                        ForEach(items, id: \.id) { (item) in
                            
                            RubbishPickupRow(item: item)
                                .padding(.all, 12)
                            
                        }
                        
                    } else {
                        
                        empty()
                        
                    }
                    
                }
                
                items.hasError { error in
                    
                    if let error = error as? RubbishDisplayError {
                        if error == .wasteScheduleDeactivated {
                            VStack {
                                Text(error.localizedDescription)
                                    .fontWeight(.semibold)
                                    .font(.callout)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }.padding()
                        }
                    }
                    
                }
                
            }
            
        }
        
    }
    
    @ViewBuilder
    private func loading() -> some View {
        
        HStack {
            Spacer()
            VStack(spacing: 12) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                Text(PackageStrings.Waste.loadingDashboard)
                    .fontWeight(.semibold)
                    .font(.callout)
            }
            Spacer()
        }
        .padding()
        
    }
    
    @ViewBuilder
    private func empty() -> some View {
        
        VStack {
            HStack(spacing: 12) {
                Image(systemName: "calendar.badge.exclamationmark")
                    .font(.largeTitle)
                Text(PackageStrings.Waste.noUpcomingRubbishItems)
            }
        }
        .padding(.top, 8)
        .padding(.horizontal)
        .padding(.bottom)
        
    }
    
}

struct PetrolDashboardView_Previews: PreviewProvider {
    
    static var previews: some View {
        
        let items = [
            RubbishPickupItem(
                date: .init(timeIntervalSinceNow: 86400),
                type: .paper
            ),
            RubbishPickupItem(
                date: .init(timeIntervalSinceNow: 86400 * 2),
                type: .organic
            ),
            RubbishPickupItem(
                date: .init(timeIntervalSinceNow: 86400 * 3),
                type: .plastic
            )
        ]
        
        return Group {
            
            RubbishDashboardPanel()
                .environment(\.locale, .init(identifier: "de"))
                .padding()
                .previewLayout(.sizeThatFits)
            
            RubbishDashboardPanel()
                .environment(\.locale, .init(identifier: "de"))
                .padding()
                .preferredColorScheme(.dark)
                .previewLayout(.sizeThatFits)
            
            RubbishDashboardPanel(items: .success(items))
                .environment(\.locale, .init(identifier: "de"))
                .padding()
                .preferredColorScheme(.dark)
                .previewLayout(.sizeThatFits)
            
            RubbishDashboardPanel(items: .success([]))
                .environment(\.locale, .init(identifier: "de"))
                .padding()
                .preferredColorScheme(.dark)
                .previewLayout(.sizeThatFits)
            
            RubbishDashboardPanel(items: .success(items))
                .environment(\.locale, .init(identifier: "de"))
                .padding()
                .previewLayout(.sizeThatFits)
            
            RubbishDashboardPanel(items: .error(RubbishDisplayError.wasteScheduleDeactivated))
                .padding()
                .environment(\.locale, .init(identifier: "de"))
                .previewLayout(.sizeThatFits)
            
        }
        
    }
    
}
