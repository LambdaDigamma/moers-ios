//
//  CompactEventsView.swift
//  
//
//  Created by Lennart Fischer on 11.04.23.
//

import SwiftUI

public struct CompactEventsView: View {

    private let viewModel: TimetableViewModel

    public init(viewModel: TimetableViewModel) {
        self.viewModel = viewModel
    }

    public var body: some View {
        TabView(selection: Binding(
            get: { viewModel.selectedDate },
            set: { viewModel.selectDate($0) }
        )) {
            ForEach(viewModel.days) { day in
                CompactDayEventsView(
                    day: day,
                    isFilterActive: !viewModel.filter.isEmpty,
                    onRefresh: viewModel.refresh
                )
                .tag(day.date)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct CompactEventsView_Previews: PreviewProvider {
    static var previews: some View {
        CompactEventsView(viewModel: TimetableViewModel())
            .preferredColorScheme(.dark)
    }
}
