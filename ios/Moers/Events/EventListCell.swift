//
//  EventListCell.swift
//  Moers
//
//  Created by Codex on 28.06.26.
//

import UIKit
import Events

final class EventListCell: UICollectionViewCell {
    static let reuseIdentifier = "EventListCell"

    private let dateContainer = UIView()
    private let dayLabel = UILabel()
    private let monthLabel = UILabel()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let metadataLabel = UILabel()
    private let favoriteImageView = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        dayLabel.text = nil
        monthLabel.text = nil
        titleLabel.text = nil
        subtitleLabel.text = nil
        metadataLabel.text = nil
        favoriteImageView.isHidden = true
    }

    func configure(with event: Event, emphasized: Bool = false) {
        if let badge = EventFormatter.dayBadge(for: event) {
            dayLabel.text = badge.day
            monthLabel.text = badge.month.uppercased()
            dateContainer.isHidden = false
        } else {
            dateContainer.isHidden = true
        }

        titleLabel.text = event.name
        subtitleLabel.text = EventFormatter.subtitle(for: event)

        let metadata = [
            event.category,
            event.attendanceTitle,
            event.extras?.isFree == true ? String(localized: "Free") : nil,
        ].compactMap { $0 }.joined(separator: " · ")
        metadataLabel.text = metadata
        metadataLabel.isHidden = metadata.isEmpty

        favoriteImageView.isHidden = !EventDetailsViewModel.isLiked(id: event.id)
        contentView.backgroundColor = emphasized ? UIColor.systemYellow.withAlphaComponent(0.12) : .secondarySystemGroupedBackground
        dateContainer.backgroundColor = emphasized ? .systemBackground : .tertiarySystemGroupedBackground
    }

    private func setup() {
        contentView.layer.cornerRadius = 12
        contentView.layer.cornerCurve = .continuous
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.separator.withAlphaComponent(0.18).cgColor
        contentView.backgroundColor = .secondarySystemGroupedBackground

        dateContainer.backgroundColor = .tertiarySystemGroupedBackground
        dateContainer.layer.cornerRadius = 9
        dateContainer.layer.cornerCurve = .continuous
        dateContainer.translatesAutoresizingMaskIntoConstraints = false

        dayLabel.font = UIFont.monospacedDigitSystemFont(ofSize: 19, weight: .semibold)
        dayLabel.adjustsFontForContentSizeCategory = true
        dayLabel.textColor = .label
        dayLabel.textAlignment = .center

        monthLabel.font = UIFont.mmEventPreferredFont(forTextStyle: .caption2, weight: .semibold)
        monthLabel.adjustsFontForContentSizeCategory = true
        monthLabel.textColor = .secondaryLabel
        monthLabel.textAlignment = .center

        let dateStack = UIStackView(arrangedSubviews: [dayLabel, monthLabel])
        dateStack.axis = .vertical
        dateStack.alignment = .center
        dateStack.spacing = -2
        dateStack.translatesAutoresizingMaskIntoConstraints = false
        dateContainer.addSubview(dateStack)

        titleLabel.font = UIFont.mmEventPreferredFont(forTextStyle: .subheadline, weight: .semibold)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 1

        subtitleLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        subtitleLabel.adjustsFontForContentSizeCategory = true
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 1

        metadataLabel.font = UIFont.mmEventPreferredFont(forTextStyle: .caption2, weight: .medium)
        metadataLabel.adjustsFontForContentSizeCategory = true
        metadataLabel.textColor = .tertiaryLabel
        metadataLabel.numberOfLines = 1

        favoriteImageView.image = UIImage(systemName: "heart.fill")
        favoriteImageView.tintColor = .systemRed
        favoriteImageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        favoriteImageView.isHidden = true

        let textStack = UIStackView(arrangedSubviews: [titleLabel, subtitleLabel, metadataLabel])
        textStack.axis = .vertical
        textStack.spacing = 3
        textStack.translatesAutoresizingMaskIntoConstraints = false

        contentView.addSubview(dateContainer)
        contentView.addSubview(textStack)
        contentView.addSubview(favoriteImageView)
        favoriteImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            dateContainer.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            dateContainer.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            dateContainer.widthAnchor.constraint(equalToConstant: 48),
            dateContainer.heightAnchor.constraint(equalToConstant: 48),

            dateStack.centerXAnchor.constraint(equalTo: dateContainer.centerXAnchor),
            dateStack.centerYAnchor.constraint(equalTo: dateContainer.centerYAnchor),

            textStack.leadingAnchor.constraint(equalTo: dateContainer.trailingAnchor, constant: 12),
            textStack.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            textStack.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            textStack.trailingAnchor.constraint(equalTo: favoriteImageView.leadingAnchor, constant: -8),

            favoriteImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            favoriteImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            favoriteImageView.widthAnchor.constraint(equalToConstant: 18),
            favoriteImageView.heightAnchor.constraint(equalToConstant: 18),
        ])
    }
    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}

}
