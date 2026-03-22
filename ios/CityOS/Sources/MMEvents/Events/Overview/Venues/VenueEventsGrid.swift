//
//  VenueEventsGrid.swift
//
//
//  Created by Lennart Fischer on 11.04.23.
//

import SwiftUI

private enum GridConstants {
    static let timeColumnWidth: CGFloat = 56
    static let venueColumnWidth: CGFloat = 180
    static let slotHeight: CGFloat = 60
    static let slotInterval: TimeInterval = 30 * 60
    static let headerHeight: CGFloat = 44
    static let eventPadding: CGFloat = 2
    static let minEventHeight: CGFloat = 28
}

struct VenueEventsGrid: View {

    @ObservedObject var viewModel: TimetableViewModel
    @EnvironmentObject private var transmitter: TimetableTransmitter

    @State private var selectedPage = 0

    var body: some View {

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

            gridContent()

        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onAppear {
            syncSelectedPageFromModel()
        }
        .onChange(of: viewModel.selectedDate) { _ in
            syncSelectedPageFromModel()
        }
        .onChange(of: viewModel.days.map(\.id)) { _ in
            syncSelectedPageFromModel()
        }

    }

    // MARK: - Day selection (same pattern as CompactEventsView)

    private var selectedDate: Date {
        guard viewModel.days.indices.contains(selectedPage) else {
            return viewModel.selectedDate
        }
        return viewModel.days[selectedPage].date
    }

    private func selectPage(for date: Date) {
        guard let index = viewModel.days.firstIndex(where: {
            Calendar.autoupdatingCurrent.isDate($0.date, inSameDayAs: date)
        }) else { return }
        guard selectedPage != index else { return }
        withAnimation(.default) {
            selectedPage = index
        }
        viewModel.selectDate(date)
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

    // MARK: - Grid content

    @ViewBuilder
    private func gridContent() -> some View {

        let dayEvents = viewModel.eventsForSelectedDay()
        let timedEvents = dayEvents.filter { $0.startDate != nil && $0.location != nil }
        let venues = viewModel.venues

        if timedEvents.isEmpty {
            VStack(spacing: 16) {
                Image(systemName: "calendar")
                    .font(.system(size: 48))
                    .foregroundColor(.secondary)
                Text(EventPackageStrings.noEventsForFilter)
                    .multilineTextAlignment(.center)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else if let timeRange = computeTimeRange(for: timedEvents), !venues.isEmpty {
            gridBody(
                venues: venues,
                timedEvents: timedEvents,
                timeRange: timeRange
            )
        }

    }

    @ViewBuilder
    private func gridBody(
        venues: [String],
        timedEvents: [EventListItemViewModel],
        timeRange: (start: Date, end: Date)
    ) -> some View {

        let timeSlots = generateTimeSlots(from: timeRange.start, to: timeRange.end)
        let totalHeight = CGFloat(timeSlots.count) * GridConstants.slotHeight
        let totalWidth = GridConstants.timeColumnWidth + CGFloat(venues.count) * GridConstants.venueColumnWidth

        ScrollView([.vertical, .horizontal], showsIndicators: true) {

            VStack(alignment: .leading, spacing: 0) {

                // Header row: time spacer + venue headers
                HStack(alignment: .center, spacing: 0) {
                    Color.clear
                        .frame(
                            width: GridConstants.timeColumnWidth,
                            height: GridConstants.headerHeight
                        )

                    ForEach(venues, id: \.self) { venue in
                        Text(venue)
                            .font(.caption)
                            .fontWeight(.medium)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 4)
                            .frame(
                                width: GridConstants.venueColumnWidth,
                                height: GridConstants.headerHeight
                            )
                            .background(Color.tertiarySystemFill)
                    }
                }

                Divider()

                // Grid body with time labels + event blocks
                ZStack(alignment: .topLeading) {

                    // Time grid lines and labels
                    ForEach(Array(timeSlots.enumerated()), id: \.offset) { index, slot in
                        let y = CGFloat(index) * GridConstants.slotHeight

                        // Time label
                        Text(slot, format: .dateTime.hour().minute())
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .frame(width: GridConstants.timeColumnWidth - 8, alignment: .trailing)
                            .offset(x: 0, y: y)

                        // Horizontal grid line
                        Rectangle()
                            .fill(Color.secondary.opacity(0.15))
                            .frame(
                                width: totalWidth - GridConstants.timeColumnWidth,
                                height: 0.5
                            )
                            .offset(x: GridConstants.timeColumnWidth, y: y)
                    }

                    // Vertical dividers between venues
                    ForEach(0..<venues.count, id: \.self) { index in
                        let x = GridConstants.timeColumnWidth + CGFloat(index) * GridConstants.venueColumnWidth
                        Rectangle()
                            .fill(Color.secondary.opacity(0.1))
                            .frame(width: 0.5, height: totalHeight)
                            .offset(x: x, y: 0)
                    }

                    // Event blocks
                    ForEach(timedEvents) { event in
                        if let startDate = event.startDate,
                           let location = event.location,
                           let venueIndex = venues.firstIndex(of: location) {

                            let endDate = event.endDate ?? startDate.addingTimeInterval(EventUtilities.defaultTimeInterval)
                            let y = yOffset(for: startDate, rangeStart: timeRange.start)
                            let x = GridConstants.timeColumnWidth + CGFloat(venueIndex) * GridConstants.venueColumnWidth + GridConstants.eventPadding
                            let height = max(eventHeight(start: startDate, end: endDate), GridConstants.minEventHeight)

                            eventBlock(event: event, height: height)
                                .offset(x: x, y: y)
                        }
                    }

                }
                .frame(width: totalWidth, height: totalHeight, alignment: .topLeading)

            }

        }
        .modifier(NoBounceModifier())

    }

    // MARK: - Event block

    @ViewBuilder
    private func eventBlock(event: EventListItemViewModel, height: CGFloat) -> some View {

        Button {
            if let eventID = event.eventID {
                transmitter.dispatchShowEvent(eventID)
            }
        } label: {
            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(.caption2)
                    .fontWeight(.semibold)
                    .lineLimit(height > 40 ? 2 : 1)
                    .foregroundColor(.primary)

                if height > 40, let startDate = event.startDate {
                    Text(startDate, style: .time)
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding(4)
            .frame(
                width: GridConstants.venueColumnWidth - GridConstants.eventPadding * 2,
                height: height,
                alignment: .topLeading
            )
            .background(event.color.opacity(0.2))
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .strokeBorder(event.color, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)

    }

    // MARK: - Time calculations

    private func computeTimeRange(for events: [EventListItemViewModel]) -> (start: Date, end: Date)? {
        let startDates = events.compactMap(\.startDate)
        guard let earliest = startDates.min() else { return nil }

        let endDates = events.compactMap { $0.endDate ?? $0.startDate?.addingTimeInterval(EventUtilities.defaultTimeInterval) }
        let latest = endDates.max() ?? earliest.addingTimeInterval(3600)

        let cal = Calendar.autoupdatingCurrent
        guard let startInterval = cal.dateInterval(of: .hour, for: earliest) else { return nil }
        let startHour = startInterval.start

        guard let endInterval = cal.dateInterval(of: .hour, for: latest) else { return nil }
        let endHour = cal.date(byAdding: .hour, value: 1, to: endInterval.start) ?? latest

        return (startHour, endHour)
    }

    private func generateTimeSlots(from start: Date, to end: Date) -> [Date] {
        var slots: [Date] = []
        var current = start
        while current <= end {
            slots.append(current)
            current = current.addingTimeInterval(GridConstants.slotInterval)
        }
        return slots
    }

    private func yOffset(for date: Date, rangeStart: Date) -> CGFloat {
        let interval = date.timeIntervalSince(rangeStart)
        return CGFloat(interval / GridConstants.slotInterval) * GridConstants.slotHeight
    }

    private func eventHeight(start: Date, end: Date) -> CGFloat {
        let duration = end.timeIntervalSince(start)
        return CGFloat(duration / GridConstants.slotInterval) * GridConstants.slotHeight
    }

}

private struct NoBounceModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .onAppear {
                UIScrollView.appearance().bounces = false
            }
            .onDisappear {
                UIScrollView.appearance().bounces = true
            }
    }
}

struct VenueEventsGrid_Previews: PreviewProvider {
    static var previews: some View {
        VenueEventsGrid(viewModel: TimetableViewModel())
            .preferredColorScheme(.dark)
    }
}
