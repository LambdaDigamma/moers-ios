//
//  DaySelector.swift
//  
//
//  Created by Lennart Fischer on 11.04.23.
//

import SwiftUI

struct DaySelector: View {
    
    @Binding var selectedDate: Date
    
    var dates: [Date]
    
    var body: some View {
        
        HStack(spacing: 20) {
            
            ForEach(dates, id: \.self) { date in
                Button(action: {
                    withAnimation {
                        selectedDate = date
                    }
                }) {
                    DayItem(date: date, isActive: isSameDay(lhs: date, rhs: selectedDate))
                }
            }
            
        }
        
    }

    func isSameDay(lhs: Date, rhs: Date) -> Bool {
        
        return CalendarUtils.dateToRequiredComponents(day: lhs) ==
            CalendarUtils.dateToRequiredComponents(day: rhs)
        
    }
    
}

struct DaySelector_Previews: PreviewProvider {
    static var previews: some View {
        DaySelector(selectedDate: .constant(Date()), dates: [
            Date(),
            Date(timeIntervalSinceNow: 60 * 60 * 24),
            Date(timeIntervalSinceNow: 60 * 60 * 24 * 2)
        ])
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
