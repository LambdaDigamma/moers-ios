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

        ViewThatFits(in: .horizontal) {
            dayButtons

            ScrollViewReader { proxy in
                ScrollView(.horizontal) {
                    dayButtons
                        .fixedSize(horizontal: true, vertical: false)
                        .background {
                            GeometryReader { geometry in
                                Color.clear.onChange(of: geometry.size) { _, _ in
                                    scrollToSelectedDay(using: proxy)
                                }
                            }
                        }
                }
                .scrollIndicators(.hidden)
                .background {
                    GeometryReader { geometry in
                        Color.clear.onChange(of: geometry.size) { _, _ in
                            scrollToSelectedDay(using: proxy)
                        }
                    }
                }
                .onAppear {
                    scrollToSelectedDay(using: proxy)
                }
                .onChange(of: selectedDay) { _, _ in
                    scrollToSelectedDay(using: proxy)
                }
                .onChange(of: dates) { _, _ in
                    scrollToSelectedDay(using: proxy)
                }
            }
        }
        .fixedSize(horizontal: false, vertical: true)
        .accessibilityIdentifier("DaySelector")

    }

    private var selectedDay: Date? {
        dates.first { isSameDay(lhs: $0, rhs: selectedDate) }
    }

    private func scrollToSelectedDay(using proxy: ScrollViewProxy) {
        if let selectedDay {
            proxy.scrollTo(selectedDay, anchor: .center)
        }
    }

    private var dayButtons: some View {
        HStack(spacing: 8) {

            ForEach(dates, id: \.self) { date in
                Button(action: {
                    onSelectDate(date)
                }) {
                    DayItem(date: date, isActive: isSameDay(lhs: date, rhs: selectedDate))
                        .frame(maxWidth: .infinity)
                        .contentShape(Rectangle())
                }
                .buttonStyle(.plain)
                .contentShape(Rectangle())
                .accessibilityIdentifier("DayItem-\(date.formatted(.dateTime.year().month().day()))")
                .accessibilityLabel(Text(date, format: .dateTime.weekday(.wide).day().month()))
                .accessibilityAddTraits(isSameDay(lhs: date, rhs: selectedDate) ? .isSelected : [])
                .id(date)
            }

        }
    }

    private func isSameDay(lhs: Date, rhs: Date) -> Bool {
        
        return CalendarUtils.dateToRequiredComponents(day: lhs) ==
            CalendarUtils.dateToRequiredComponents(day: rhs)
        
    }
    
}

struct DaySelector_Previews: PreviewProvider {
    private static let dates = (21...25).compactMap {
        Calendar(identifier: .gregorian).date(from: DateComponents(year: 2026, month: 5, day: $0, hour: 12))
    }

    static var previews: some View {
        preview(width: 340, textSize: .large)
            .previewDisplayName("Programme column")

        preview(width: 280, textSize: .large)
            .previewDisplayName("Narrow scrolling strip")

        preview(width: 340, textSize: .accessibility3)
            .previewDisplayName("Larger text")

        preview(width: 420, textSize: .large)
            .environment(\.locale, Locale(identifier: "de"))
            .previewDisplayName("German wide column")
    }

    private static func preview(width: CGFloat, textSize: DynamicTypeSize) -> some View {
        DaySelector(selectedDate: dates[1], dates: dates, onSelectDate: { _ in })
            .padding(.horizontal)
            .padding(.vertical, 8)
            .frame(width: width)
            .dynamicTypeSize(textSize)
            .previewLayout(.sizeThatFits)
    }
}
