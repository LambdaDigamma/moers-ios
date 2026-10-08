//
//  EventSubtitleView.swift
//  
//
//  Created by Lennart Fischer on 20.05.22.
//

import Foundation
import SwiftUI

#if canImport(UIKit)
import UIKit
#endif


public struct EventSubtitleView: View {
    
    @Environment(\.scenePhase) private var scenePhase
    @State private var now = Date()
    @State private var refreshTask: Task<Void, Never>?

    private let startDate: Date?
    private let endDate: Date?
    private let fixedTimeDisplayMode: TimeDisplayMode?
    private let scheduleDisplayMode: EventScheduleDisplayMode?
    private let location: String?
    private let isOpenEnd: Bool
    
    public init(
        startDate: Date?,
        endDate: Date?,
        scheduleDisplayMode: EventScheduleDisplayMode,
        location: String? = nil,
        isOpenEnd: Bool = false
    ) {
        self.startDate = startDate
        self.endDate = endDate
        self.fixedTimeDisplayMode = nil
        self.scheduleDisplayMode = scheduleDisplayMode
        self.location = location
        self.isOpenEnd = isOpenEnd
    }

    public init(viewModel: EventListItemViewModel) {
        self.init(
            startDate: viewModel.startDate,
            endDate: viewModel.endDate,
            scheduleDisplayMode: viewModel.scheduleDisplayMode,
            location: viewModel.location,
            isOpenEnd: viewModel.isOpenEnd
        )
    }

    public init(
        startDate: Date?,
        endDate: Date?,
        timeDisplayMode: TimeDisplayMode,
        location: String? = nil
    ) {
        self.startDate = startDate
        self.endDate = endDate
        self.fixedTimeDisplayMode = timeDisplayMode
        self.scheduleDisplayMode = nil
        self.location = location
        self.isOpenEnd = false
    }
    
    public var body: some View {
        content(at: now)
            .onAppear {
                refreshNowAndRestartTask()
            }
            .onDisappear {
                refreshTask?.cancel()
                refreshTask = nil
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    refreshNowAndRestartTask()
                }
            }
            .onChange(of: startDate) {
                refreshNowAndRestartTask()
            }
            .onChange(of: endDate) {
                refreshNowAndRestartTask()
            }
            .onChange(of: scheduleDisplayMode) {
                refreshNowAndRestartTask()
            }
            .onChange(of: isOpenEnd) {
                refreshNowAndRestartTask()
            }
            .refreshOnAppLifecycle {
                refreshNowAndRestartTask()
            }
    }

}

private extension EventSubtitleView {

    static let maximumSleepInterval: TimeInterval = 60 * 60 * 24

    @ViewBuilder
    func content(at now: Date) -> some View {
        HStack(alignment: .center, spacing: 0) {
            switch timeDisplayMode(at: now) {
                case .live:
                    (location != nil ? Text("\(location ?? "")") : Text(""))
                        .lineLimit(1)

                    Spacer()

                    LiveBadge()

                case .relative:
                    if let startDate = startDate {
                        (
                            Text(EventUtilities.relativeTimeText(startDate: startDate, now: now))
                            + locationSuffix()
                        )
                            .lineLimit(1)
                    }

                case .range:
                    if !isOpenEnd,
                       let dateRange = EventUtilities.dateRange(startDate: startDate, endDate: endDate) {
                        (Text(dateRange) + locationSuffix())
                            .lineLimit(1)
                    } else if let startDate = startDate, showsTimeComponent {
                        (Text(startDate, style: .time) + locationSuffix())
                            .lineLimit(1)
                    } else if let location, !showsDateComponent {
                        Text(location)
                            .lineLimit(1)
                    } else {
                        Text(EventPackageStrings.notYetScheduled)
                            .lineLimit(1)
                    }

                case .date:
                    if let startDate = startDate {
                        (Text(startDate, style: .date) + locationSuffix())
                            .lineLimit(1)
                    } else if let location = location {
                        Text(location)
                            .lineLimit(1)
                    } else {
                        Text(EventPackageStrings.notYetScheduled)
                            .lineLimit(1)
                    }

                case .none:
                    if let location = location {
                        Text(location)
                            .lineLimit(1)
                    } else {
                        Text(EventPackageStrings.notYetScheduled)
                            .lineLimit(1)
                    }
            }
        }
        .foregroundColor(.secondary)
        .font(.callout)
    }

    var showsDateComponent: Bool {
        if let scheduleDisplayMode {
            return scheduleDisplayMode.showsDateComponent
        }

        guard let fixedTimeDisplayMode else {
            return false
        }

        return fixedTimeDisplayMode != .none
    }

    var showsTimeComponent: Bool {
        scheduleDisplayMode?.showsTimeComponent ?? true
    }

    func timeDisplayMode(at now: Date) -> TimeDisplayMode {
        if let fixedTimeDisplayMode {
            return fixedTimeDisplayMode
        }

        guard let scheduleDisplayMode else {
            return .none
        }

        return EventUtilities.timeDisplayMode(
            startDate: startDate,
            endDate: endDate,
            scheduleDisplayMode: scheduleDisplayMode,
            now: now
        )
    }

    func locationSuffix() -> Text {
        if let location {
            return Text(" · \(location)")
        }

        return Text("")
    }

    func refreshNowAndRestartTask() {
        now = Date()
        restartRefreshTask()
    }

    func restartRefreshTask() {
        refreshTask?.cancel()

        guard fixedTimeDisplayMode == nil else {
            refreshTask = nil
            return
        }

        refreshTask = Task { @MainActor in
            while !Task.isCancelled {
                guard let scheduleDisplayMode else {
                    break
                }

                let currentDate = Date()

                guard let nextUpdateDate = EventUtilities.nextTimeDisplayUpdateDate(
                    startDate: startDate,
                    endDate: endDate,
                    scheduleDisplayMode: scheduleDisplayMode,
                    after: currentDate
                ) else {
                    break
                }

                let interval = min(
                    max(nextUpdateDate.timeIntervalSince(Date()), 0),
                    Self.maximumSleepInterval
                )
                let nanoseconds = UInt64(interval * 1_000_000_000)

                if nanoseconds > 0 {
                    try? await Task.sleep(nanoseconds: nanoseconds)
                } else {
                    await Task.yield()
                }

                guard !Task.isCancelled else {
                    return
                }

                now = Date()
            }

            refreshTask = nil
        }
    }

}

private extension View {

    @ViewBuilder
    func refreshOnAppLifecycle(_ refresh: @escaping () -> Void) -> some View {
        #if canImport(UIKit)
        self
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                refresh()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
                refresh()
            }
            .onReceive(NotificationCenter.default.publisher(for: UIApplication.significantTimeChangeNotification)) { _ in
                refresh()
            }
        #else
        self
        #endif
    }

}
