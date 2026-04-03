//
//  DaySelector.swift
//  
//
//  Created by Lennart Fischer on 11.04.23.
//

import SwiftUI

struct DaySelector: View {
    
    let selectedDate: Date
    let dates: [Date]
    let onSelectDate: (Date) -> Void
    
    var body: some View {

        HStack(spacing: 20) {

            ForEach(dates, id: \.self) { date in
                Button(action: {
                    onSelectDate(date)
                }) {
                    DayItem(date: date, isActive: isSameDay(lhs: date, rhs: selectedDate))
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
                .accessibilityIdentifier("DayItem-\(date.formatted(.dateTime.year().month().day()))")
                .accessibilityLabel(date.formatted(.dateTime.weekday(.wide).day().month()))
            }

        }
        .accessibilityIdentifier("DaySelector")

    }

    func isSameDay(lhs: Date, rhs: Date) -> Bool {
        
        return CalendarUtils.dateToRequiredComponents(day: lhs) ==
            CalendarUtils.dateToRequiredComponents(day: rhs)
        
    }
    
}

struct DaySelector_Previews: PreviewProvider {
    static var previews: some View {
        DaySelector(
            selectedDate: Date(),
            dates: [
                Date(),
                Date(timeIntervalSinceNow: 60 * 60 * 24),
                Date(timeIntervalSinceNow: 60 * 60 * 24 * 2)
            ],
            onSelectDate: { _ in }
        )
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
