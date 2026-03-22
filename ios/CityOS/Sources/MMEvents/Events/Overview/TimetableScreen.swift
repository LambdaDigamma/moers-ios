//
//  TimetableScreen.swift
//  
//
//  Created by Lennart Fischer on 11.04.23.
//

import SwiftUI

public struct TimetableScreen: View {
    
    @State private var search = ""
    @AppStorage("currentEventDisplayMode") private var displayMode: DailyEventsDisplayMode = .compact
    @State private var showingFilter = false
    
    @StateObject private var viewModel = TimetableViewModel()
    
    public init() {
        
    }
    
    public var body: some View {
        
        VStack(spacing: 0) {
            
            if !viewModel.filter.isEmpty {
                HStack {
                    Image(systemName: "line.3.horizontal.decrease.circle.fill")
                        .foregroundColor(.accentColor)
                    Text(EventPackageStrings.filterActive)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    Spacer()
                    
                    Button(EventPackageStrings.clearFilter) {
                        viewModel.filter = .empty
                    }
                    .font(.subheadline.bold())
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color.clear)
            }
            
            ZStack {
    
                if viewModel.allEventsHideSchedule {
    
                    PreviewListEventsView()
    
                } else {
    
                    switch displayMode {
                        case .compact:
                            CompactEventsView(viewModel: viewModel)
                        case .images:
                            ExtendedEventsView(viewModel: viewModel)
                        case .venueGrid:
                            VenueEventsGrid(viewModel: viewModel)
                    }
    
                }
                
            }
            
        }
        .task {
            await viewModel.load()
        }
        .toolbar {
//            ToolbarItem(placement: .topBarLeading) {
//                Menu {
//                    ForEach(DailyEventsDisplayMode.allCases) { mode in
//                        Button {
//                            displayMode = mode
//                        } label: {
//                            Label(mode.title, systemImage: mode.systemImage)
//                        }
//                    }
//                } label: {
//                    Label(EventPackageStrings.displayMode, systemImage: displayMode.systemImage)
//                }
//            }

            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingFilter = true
                } label: {
                    Label(EventPackageStrings.filter, systemImage: viewModel.filter.isEmpty ? "line.3.horizontal.decrease.circle" : "line.3.horizontal.decrease.circle.fill")
                }
            }
        }
        .sheet(isPresented: $showingFilter) {
            EventFilterSheet(filter: $viewModel.filter)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .navigationTitle(EventPackageStrings.timetable)
        
    }
    
}

struct TimetableScreen_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            TimetableScreen()
                .navigationBarTitleDisplayMode(.inline)
                .preferredColorScheme(.dark)
        }
        .accentColor(.yellow)
    }
}
