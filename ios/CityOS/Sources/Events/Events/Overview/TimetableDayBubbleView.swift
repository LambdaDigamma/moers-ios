//
//  TimetableDayBubbleView.swift
//
//
//  Created by Claude on 24.10.26.
//

#if !os(tvOS)

import UIKit

/// A horizontally scrolling strip of capsule buttons, one per programme day.
public final class TimetableDayBubbleView: UIView {

    public var onSelectDate: ((Date) -> Void)?
    public var onSelectUnscheduled: (() -> Void)?

    private(set) var dates: [Date] = []
    private(set) var selectedDate: Date?

    private let scrollView = UIScrollView()
    private let stackView = UIStackView()
    private var buttons: [UIButton] = []
    private var includesUnscheduled = false
    private var unscheduledButton: UIButton?
    private var lastViewportSize: CGSize = .zero
    private var lastContentSize: CGSize = .zero

    nonisolated deinit {}

    public override init(frame: CGRect) {
        super.init(frame: frame)
        setupScrollView()
        setupStackView()
        accessibilityIdentifier = "DaySelector"
    }

    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        scrollView.layoutIfNeeded()

        if scrollView.bounds.size != lastViewportSize || scrollView.contentSize != lastContentSize {
            lastViewportSize = scrollView.bounds.size
            lastContentSize = scrollView.contentSize
            scrollToSelectedButton(animated: false)
        }
    }

    public func setDates(_ dates: [Date], selectedDate: Date?, includesUnscheduled: Bool = false) {
        if dates != self.dates || includesUnscheduled != self.includesUnscheduled {
            self.dates = dates
            self.includesUnscheduled = includesUnscheduled
            rebuildButtons()
        }

        setSelectedDate(selectedDate, animated: false)
    }

    public func setSelectedDate(_ date: Date?, animated: Bool) {
        selectedDate = date

        for (button, buttonDate) in zip(buttons, dates) {
            button.isSelected = date.map { Self.isSameDay($0, buttonDate) } ?? false
        }
        unscheduledButton?.isSelected = date == nil

        layoutIfNeeded()
        scrollView.layoutIfNeeded()
        scrollToSelectedButton(animated: animated)
    }

    // MARK: - Setup

    private func setupScrollView() {
        scrollView.showsHorizontalScrollIndicator = false
        scrollView.clipsToBounds = true
        scrollView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

    private func setupStackView() {
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.spacing = 10
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.insetsLayoutMarginsFromSafeArea = false
        stackView.layoutMargins = UIEdgeInsets(top: 4, left: 16, bottom: 10, right: 16)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        scrollView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: scrollView.contentLayoutGuide.topAnchor),
            stackView.bottomAnchor.constraint(equalTo: scrollView.contentLayoutGuide.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: scrollView.contentLayoutGuide.trailingAnchor),
            // The strip sizes itself to its buttons, which keeps it correct at any Dynamic Type size.
            scrollView.frameLayoutGuide.heightAnchor.constraint(equalTo: scrollView.contentLayoutGuide.heightAnchor)
        ])
    }

    private func rebuildButtons() {
        stackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        unscheduledButton = nil

        buttons = dates.enumerated().map { index, date in
            let button = makeButton(for: date, tag: index)
            stackView.addArrangedSubview(button)
            return button
        }
        if includesUnscheduled {
            let button = makeButton(
                title: EventPackageStrings.notYetScheduled,
                identifier: "DayItem-Unscheduled",
                action: { [weak self] in self?.onSelectUnscheduled?() }
            )
            stackView.addArrangedSubview(button)
            unscheduledButton = button
        }
    }

    private func makeButton(for date: Date, tag: Int) -> UIButton {
        let title = date.formatted(.dateTime.weekday(.abbreviated).day())

        let button = makeButton(
            title: title,
            identifier: EventDayAccessibilityIdentifier.day(date),
            action: { [weak self] in self?.onSelectDate?(date) }
        )
        button.tag = tag
        button.accessibilityLabel = date.formatted(.dateTime.weekday(.wide).day().month())
        return button
    }

    private func makeButton(title: String, identifier: String, action: @escaping () -> Void) -> UIButton {
        let button = UIButton(configuration: Self.configuration(isSelected: false, title: title))
        button.titleLabel?.adjustsFontForContentSizeCategory = true
        button.changesSelectionAsPrimaryAction = false
        button.configurationUpdateHandler = { button in
            button.configuration = Self.configuration(isSelected: button.isSelected, title: title)
        }
        button.addAction(UIAction { _ in action() }, for: .touchUpInside)

        button.setContentCompressionResistancePriority(.required, for: .horizontal)
        button.heightAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
        button.widthAnchor.constraint(greaterThanOrEqualToConstant: 44).isActive = true
        button.accessibilityIdentifier = identifier

        return button
    }

    private func scrollToSelectedButton(animated: Bool) {
        let selectedButton: UIButton?
        if let selectedDate, let index = dates.firstIndex(where: { Self.isSameDay($0, selectedDate) }),
           buttons.indices.contains(index) {
            selectedButton = buttons[index]
        } else if selectedDate == nil {
            selectedButton = unscheduledButton
        } else {
            selectedButton = nil
        }
        guard let button = selectedButton else { return }

        let visibleWidth = scrollView.bounds.width
        let contentWidth = scrollView.contentSize.width
        guard visibleWidth > 0, contentWidth > visibleWidth + 1 else { return }

        let centeredX = button.frame.midX - visibleWidth / 2
        let clampedX = min(max(centeredX, 0), contentWidth - visibleWidth)

        scrollView.setContentOffset(CGPoint(x: clampedX, y: 0), animated: animated)
    }

    // MARK: - Styling

    private static let selectedForeground = UIColor { traits in
        traits.userInterfaceStyle == .dark ? .black : .white
    }

    private static func configuration(isSelected: Bool, title: String) -> UIButton.Configuration {
        var configuration: UIButton.Configuration

        if #available(iOS 26.0, *) {
            configuration = isSelected ? .prominentGlass() : .glass()
            configuration.baseBackgroundColor = isSelected ? .label : nil
        } else {
            configuration = isSelected ? .filled() : .gray()
            configuration.baseBackgroundColor = isSelected ? .label : nil
        }

        configuration.baseForegroundColor = isSelected ? selectedForeground : .label
        configuration.cornerStyle = .capsule
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 12, leading: 15, bottom: 12, trailing: 15)
        configuration.title = title
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { container in
            var container = container
            container.foregroundColor = isSelected ? Self.selectedForeground : .label
            container.font = UIFontMetrics(forTextStyle: .body)
                .scaledFont(for: .monospacedDigitSystemFont(ofSize: 17, weight: .semibold))
            return container
        }

        return configuration
    }

    private static func isSameDay(_ lhs: Date, _ rhs: Date) -> Bool {
        Calendar.autoupdatingCurrent.isDate(lhs, inSameDayAs: rhs)
    }

}

#if DEBUG
#Preview("Day bubbles", traits: .fixedLayout(width: 360, height: 80)) {
    let strip = TimetableDayBubbleView()
    let today = Calendar.current.startOfDay(for: .now)
    let dates = (0..<5).compactMap { Calendar.current.date(byAdding: .day, value: $0, to: today) }
    strip.setDates(dates, selectedDate: dates[1], includesUnscheduled: true)
    return strip
}
#endif

#endif
