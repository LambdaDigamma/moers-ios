//
//  RubbishDashboardView.swift
//  Moers
//
//  Created by Lennart Fischer on 27.06.20.
//  Copyright © 2020 Lennart Fischer. All rights reserved.
//

import SwiftUI
import ModernNetworking

public struct RubbishDashboardPanel: View {
    
    @ObservedObject private var viewModel: RubbishDashboardViewModel
    
    public init(viewModel: RubbishDashboardViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        
        CardPanelView {
            
            VStack(alignment: .leading, spacing: 0) {
                
                viewModel.state.isLoading {
                    loading()
                }
                
                viewModel.state.hasResource { (items) in
                    
                    HStack {
                        Text(PackageStrings.Waste.dashboardTitle)
                            .font(.title3)
                            .fontWeight(.semibold)
                        Spacer()
                    }
                    .padding(.top, 12)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 12)
                    
                    Divider()
                    
                    if !items.isEmpty {
                        
                        VStack(alignment: .leading, spacing: 4) {
                            ForEach(Array(items.prefix(3)), id: \.id) { (item) in
                                
                                RubbishPickupRow(item: item)
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 12)
                                
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.top, 8)
                        .padding(.bottom, 12)
                        
                    } else {
                        
                        empty()
                        
                    }
                    
//                    Divider()
//
//                    Text("\(Image(systemName: "signpost.right.fill"))  Adlerstraße")
//                        .font(.caption2.weight(.medium))
//                        .foregroundColor(.secondary)
//                        .padding(.horizontal)
//                        .padding(.vertical, 12)
                    
                }
                
                viewModel.state.hasError { (error: RubbishLoadingError) in
                    
                    VStack(alignment: .leading, spacing: 8) {
                        
                        Text(error.title)
                            .fontWeight(.semibold)
                            .font(.callout)
                        
                        Text(error.text)
                            .font(.subheadline)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        
                    }
                    .padding()
                    
                }
                
            }
            
        }
        .onAppear {
            viewModel.load()
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
        
        let service = StaticRubbishService()
        
        return Group {
            
            RubbishDashboardPanel(viewModel: RubbishDashboardViewModel(
                rubbishService: service,
                initialState: .loading
            ))
                .environment(\.locale, .init(identifier: "de"))
                .padding()
                .previewLayout(.sizeThatFits)
            
            RubbishDashboardPanel(viewModel: RubbishDashboardViewModel(
                rubbishService: service,
                initialState: .loading
            ))
                .environment(\.locale, .init(identifier: "de"))
                .padding()
                .preferredColorScheme(.dark)
                .previewLayout(.sizeThatFits)
            
            RubbishDashboardPanel(viewModel: RubbishDashboardViewModel(
                rubbishService: service,
                initialState: .success(items)
            ))
                .environment(\.locale, .init(identifier: "de"))
                .padding()
                .preferredColorScheme(.dark)
                .previewLayout(.sizeThatFits)
            
            RubbishDashboardPanel(viewModel: RubbishDashboardViewModel(
                rubbishService: service,
                initialState: .success([])
            ))
                .environment(\.locale, .init(identifier: "de"))
                .padding()
                .preferredColorScheme(.dark)
                .previewLayout(.sizeThatFits)
            
            RubbishDashboardPanel(viewModel: RubbishDashboardViewModel(
                rubbishService: service,
                initialState: .success(items)
            ))
                .environment(\.locale, .init(identifier: "de"))
                .padding()
                .previewLayout(.sizeThatFits)
            
            RubbishDashboardPanel(viewModel: RubbishDashboardViewModel(
                rubbishService: service,
                initialState: .error(.deactivated)
            ))
                .padding()
                .environment(\.locale, .init(identifier: "de"))
                .previewLayout(.sizeThatFits)
            
        }
        
    }
    
}
