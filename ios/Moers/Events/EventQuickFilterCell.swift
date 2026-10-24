//
//  EventQuickFilterCell.swift
//  Moers
//
//  Created by Codex on 28.06.26.
//

import UIKit
import SwiftUI

final class EventQuickFilterCell: UICollectionViewCell {
    static let reuseIdentifier = "EventQuickFilterCell"

    private let symbolView = UIImageView()
    private let titleLabel = UILabel()
    private let stackView = UIStackView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        symbolView.image = nil
        titleLabel.text = nil
        isSelected = false
    }

    func configure(with filter: EventQuickFilter, isSelected: Bool) {
        symbolView.image = UIImage(systemName: filter.systemImageName)
        titleLabel.text = filter.title
        isAccessibilityElement = true
        accessibilityLabel = filter.title
        accessibilityIdentifier = "events.quickFilter.\(filter)"
        accessibilityTraits = isSelected ? [.button, .selected] : [.button]
        applySelection(isSelected)
    }

    private func setup() {
        contentView.layer.cornerRadius = 16
        contentView.layer.cornerCurve = .continuous
        contentView.layer.masksToBounds = true

        symbolView.contentMode = .scaleAspectFit
        symbolView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 12, weight: .semibold)
        symbolView.setContentHuggingPriority(.required, for: .horizontal)

        titleLabel.font = UIFont.mmEventPreferredFont(forTextStyle: .footnote, weight: .semibold)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.numberOfLines = 0
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)

        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.spacing = 6
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.addArrangedSubview(symbolView)
        stackView.addArrangedSubview(titleLabel)

        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            stackView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            stackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
        ])
    }

    private func applySelection(_ selected: Bool) {
        let foregroundColor: UIColor = selected ? .black : .label
        contentView.backgroundColor = selected ? .systemYellow : .secondarySystemGroupedBackground
        contentView.layer.borderWidth = selected ? 0 : 1
        contentView.layer.borderColor = UIColor.separator.withAlphaComponent(0.35).cgColor
        titleLabel.textColor = foregroundColor
        symbolView.tintColor = foregroundColor
    }
    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}

}

#Preview("Event filter", traits: .fixedLayout(width: 180, height: 44)) {
    let cell = EventQuickFilterCell()
    cell.configure(with: .withImages, isSelected: true)
    return cell
}

#Preview("Event filter · Accessibility", traits: .fixedLayout(width: 320, height: 120)) {
    let cell = EventQuickFilterCell()
    cell.traitOverrides.preferredContentSizeCategory = .accessibilityExtraExtraExtraLarge
    cell.configure(with: .withImages, isSelected: true)
    return cell
}
