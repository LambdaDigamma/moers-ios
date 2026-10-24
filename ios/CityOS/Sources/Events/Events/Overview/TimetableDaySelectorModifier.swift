import SwiftUI

struct TimetableDaySelectorModifier: ViewModifier {
    let selectedDate: Date
    let dates: [Date]
    let onSelectDate: (Date) -> Void

    func body(content: Content) -> some View {
        if dates.isEmpty {
            content
        } else if #available(iOS 26.0, macOS 26.0, tvOS 26.0, watchOS 26.0, *) {
            content.safeAreaBar(edge: .top, spacing: 0) {
                selector
            }
        } else {
            content.safeAreaInset(edge: .top, spacing: 0) {
                selector.background(.regularMaterial)
            }
        }
    }

    private var selector: some View {
        DaySelector(selectedDate: selectedDate, dates: dates, onSelectDate: onSelectDate)
    }
}
