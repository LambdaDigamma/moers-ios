//
//  ExtendedEventsView.swift
//  
//
//  Created by Lennart Fischer on 14.04.23.
//

import SwiftUI

public struct ExtendedEventsView: View {
    
    @ObservedObject var viewModel: TimetableViewModel
    
    public init(viewModel: TimetableViewModel) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }
    
    public var body: some View {
        
        VStack(spacing: 0) {
            
            VStack(spacing: 0) {
                
                DaySelector(selectedDate: $viewModel.selectedDate, dates: viewModel.dates)
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                
                Divider()
                
            }
            
            TabView(selection: $viewModel.selectedDate) {
                
                ForEach(viewModel.dates, id: \.self) { date in
                    
                    ExtendedDayEventsView(date: date)
                        .tag(date)
                    
                }
                
            }.tabViewStyle(.page(indexDisplayMode: .never))
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        
    }
    
}
