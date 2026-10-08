//
//  EventFilterViewController.swift
//  Moers
//
//  Created by Codex on 28.06.26.
//

import UIKit
import SwiftUI

final class EventFilterViewController: UITableViewController {

    var onApply: ((EventFilter) -> Void)?

    private var filter: EventFilter
    private let options: EventFilterOptions
    private var rowsBySection: [EventFilterSection: [EventFilterOption]] = [:]

    init(filter: EventFilter, options: EventFilterOptions) {
        self.filter = filter
        self.options = options
        super.init(style: .insetGrouped)
        buildRows()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        title = String(localized: "Filter")
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: String(localized: "Reset"),
            style: .plain,
            target: self,
            action: #selector(resetFilters)
        )
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            systemItem: .done,
            primaryAction: UIAction { [weak self] _ in
                self?.applyAndDismiss()
            }
        )

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "FilterCell")
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        EventFilterSection.allCases.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sectionType(for: section).title
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        rowsBySection[sectionType(for: section), default: []].count
    }

    override func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FilterCell", for: indexPath)
        let option = option(at: indexPath)

        var content = cell.defaultContentConfiguration()
        content.text = option.title
        cell.contentConfiguration = content
        cell.accessoryType = isSelected(option) ? .checkmark : .none
        cell.tintColor = .systemYellow

        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        toggle(option(at: indexPath))
        tableView.reloadSections(IndexSet(integer: indexPath.section), with: .automatic)
    }

    private func buildRows() {
        rowsBySection[.date] = EventDateScope.allCases.map { .date($0) }
        rowsBySection[.flags] = [.favorites, .withImages] + (options.supportsFreeFilter ? [.free] : [])
        rowsBySection[.attendance] = options.attendanceModes.map { .attendanceMode($0) }
        rowsBySection[.categories] = options.categories.map { .category($0) }
        rowsBySection[.venues] = options.venues.map { .venue($0) }
        rowsBySection[.organizers] = options.organizers.map { .organizer($0) }
    }

    private func sectionType(for section: Int) -> EventFilterSection {
        EventFilterSection(rawValue: section) ?? .date
    }

    private func option(at indexPath: IndexPath) -> EventFilterOption {
        rowsBySection[sectionType(for: indexPath.section), default: []][indexPath.row]
    }

    private func isSelected(_ option: EventFilterOption) -> Bool {
        switch option {
        case .date(let scope):
            return filter.dateScope == scope
        case .favorites:
            return filter.onlyFavorites
        case .withImages:
            return filter.onlyWithImages
        case .free:
            return filter.onlyFree
        case .attendanceMode(let mode):
            return filter.attendanceModes.contains(mode)
        case .category(let category):
            return filter.categories.contains(category)
        case .venue(let venue):
            return filter.venues.contains(venue)
        case .organizer(let organizer):
            return filter.organizers.contains(organizer)
        }
    }

    private func toggle(_ option: EventFilterOption) {
        switch option {
        case .date(let scope):
            filter.dateScope = scope
        case .favorites:
            filter.onlyFavorites.toggle()
        case .withImages:
            filter.onlyWithImages.toggle()
        case .free:
            filter.onlyFree.toggle()
        case .attendanceMode(let mode):
            filter.attendanceModes.toggle(mode)
        case .category(let category):
            filter.categories.toggle(category)
        case .venue(let venue):
            filter.venues.toggle(venue)
        case .organizer(let organizer):
            filter.organizers.toggle(organizer)
        }
    }

    @objc private func resetFilters() {
        filter = EventFilter()
        tableView.reloadData()
    }

    private func applyAndDismiss() {
        onApply?(filter)
        dismiss(animated: true)
    }
    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}

}

#Preview("Event filters") {
    UINavigationController(rootViewController: EventFilterViewController(
        filter: EventFilter(),
        options: EventFilterOptions(events: [])
    ))
}
