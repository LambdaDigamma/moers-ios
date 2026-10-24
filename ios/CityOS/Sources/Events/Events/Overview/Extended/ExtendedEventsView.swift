//
//  ExtendedEventsView.swift
//  
//
//  Created by Lennart Fischer on 14.04.23.
//

import SwiftUI

public struct ExtendedEventsView: View {

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
                ExtendedDayEventsView(
                    day: day,
                    isFilterActive: !viewModel.filter.isEmpty
                )
                .tag(day.date)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
