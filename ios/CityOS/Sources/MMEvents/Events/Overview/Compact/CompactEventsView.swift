//
//  CompactEventsView.swift
//  
//
//  Created by Lennart Fischer on 11.04.23.
//

import SwiftUI

public struct CompactEventsView: View {
    
    @ObservedObject private var viewModel: TimetableViewModel
    @State private var selectedPage = 0
    
    public init(viewModel: TimetableViewModel) {
        self._viewModel = ObservedObject(wrappedValue: viewModel)
    }
    
    private var selectedDate: Date {
        guard viewModel.days.indices.contains(selectedPage) else {
            return viewModel.selectedDate
        }
        
        return viewModel.days[selectedPage].date
    }
    
    public var body: some View {
        
        VStack(spacing: 0) {
            
            VStack(spacing: 0) {
                
                DaySelector(
                    selectedDate: selectedDate,
                    dates: viewModel.dates,
                    onSelectDate: selectPage(for:)
                )
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                
                Divider()
                
            }
            
            TabView(selection: $selectedPage) {
                
                ForEach(Array(viewModel.days.enumerated()), id: \.element.id) { index, day in
                    
                    CompactDayEventsView(
                        day: day,
                        isFilterActive: !viewModel.filter.isEmpty,
                        onRefresh: viewModel.refresh
                    )
                        .tag(index)
                    
                }
                
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .onChange(of: selectedPage) { newValue in
                guard viewModel.days.indices.contains(newValue) else { return }
                viewModel.selectDate(viewModel.days[newValue].date)
            }
            .onChange(of: viewModel.selectedDate) { _ in
                syncSelectedPageFromModel()
            }
            .onChange(of: viewModel.days.map(\.id)) { _ in
                syncSelectedPageFromModel()
            }
            
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            syncSelectedPageFromModel()
        }
        
    }
    
    private func selectPage(for date: Date) {
        
        guard let index = viewModel.days.firstIndex(where: {
            Calendar.autoupdatingCurrent.isDate($0.date, inSameDayAs: date)
        }) else { return }
        
        selectedPage = index
    }
    
    private func syncSelectedPageFromModel() {
        
        guard let index = viewModel.days.firstIndex(where: {
            Calendar.autoupdatingCurrent.isDate($0.date, inSameDayAs: viewModel.selectedDate)
        }) else {
            selectedPage = 0
            return
        }
        
        guard selectedPage != index else { return }
        
        selectedPage = index
    }
    
}

struct CompactEventsView_Previews: PreviewProvider {
    static var previews: some View {
        CompactEventsView(viewModel: TimetableViewModel())
            .preferredColorScheme(.dark)
    }
}
