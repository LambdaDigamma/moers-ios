//
//  EventSpotlightCell.swift
//  Moers
//
//  Created by Codex on 28.06.26.
//

import UIKit
import SwiftUI
import Events

final class EventSpotlightCell: UICollectionViewCell {
    static let reuseIdentifier = "EventSpotlightCell"

    private let imageView = EventAsyncImageView()
    private let imageContainerView = UIView()
    private let categoryLabel = UILabel()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let favoriteImageView = UIImageView()
    private let dateLabel = UILabel()
    private let textStack = UIStackView()
    private let eyebrowStack = UIStackView()
    private var textLeadingConstraint: NSLayoutConstraint!
    private var accessibleTextLeadingConstraint: NSLayoutConstraint!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.cancelImageLoad()
        imageView.image = nil
        categoryLabel.text = nil
        titleLabel.text = nil
        subtitleLabel.text = nil
        dateLabel.text = nil
        favoriteImageView.isHidden = true
    }

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        let attributes = super.preferredLayoutAttributesFitting(layoutAttributes)
        let width = layoutAttributes.size.width
        contentView.bounds.size.width = width
        contentView.setNeedsLayout()
        contentView.layoutIfNeeded()
        // The nested stacks otherwise keep a one-line intrinsic height at narrow widths.
        for label in [categoryLabel, dateLabel, titleLabel, subtitleLabel] where label.numberOfLines != 1 {
            label.preferredMaxLayoutWidth = label.bounds.width
        }
        let size = contentView.systemLayoutSizeFitting(
            CGSize(width: width, height: UIView.layoutFittingCompressedSize.height),
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )
        attributes.size.height = ceil(size.height)
        return attributes
    }

    func configure(with event: Event) {
        imageView.setImage(url: event.image)
        let categoryText = event.category ?? (event.attendanceTitle)
        categoryLabel.text = categoryText
        categoryLabel.isHidden = categoryLabel.text == nil
        titleLabel.text = event.name
        subtitleLabel.text = EventFormatter.subtitle(for: event)
        dateLabel.text = EventFormatter.compactDate(for: event)
        dateLabel.isHidden = dateLabel.text == nil
        favoriteImageView.isHidden = !EventDetailsViewModel.isLiked(id: event.id)
    }

    private func setup() {
        contentView.layer.cornerRadius = 14
        contentView.layer.cornerCurve = .continuous
        contentView.layer.masksToBounds = true
        contentView.backgroundColor = .secondarySystemGroupedBackground
        contentView.layer.borderWidth = 1
        contentView.layer.borderColor = UIColor.separator.withAlphaComponent(0.22).cgColor

        imageContainerView.layer.cornerRadius = 10
        imageContainerView.layer.cornerCurve = .continuous
        imageContainerView.layer.masksToBounds = true
        imageContainerView.backgroundColor = .tertiarySystemGroupedBackground
        imageContainerView.translatesAutoresizingMaskIntoConstraints = false

        imageView.contentMode = .scaleAspectFill
        imageView.translatesAutoresizingMaskIntoConstraints = false

        categoryLabel.font = UIFont.mmEventPreferredFont(forTextStyle: .caption2, weight: .semibold)
        categoryLabel.adjustsFontForContentSizeCategory = true
        categoryLabel.textColor = .tertiaryLabel
        categoryLabel.numberOfLines = 1
        categoryLabel.lineBreakMode = .byTruncatingTail

        titleLabel.font = UIFont.mmEventPreferredFont(forTextStyle: .subheadline, weight: .semibold)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 2

        subtitleLabel.font = UIFont.preferredFont(forTextStyle: .footnote)
        subtitleLabel.adjustsFontForContentSizeCategory = true
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 2

        dateLabel.font = UIFont.mmEventPreferredFont(forTextStyle: .caption1, weight: .semibold)
        dateLabel.adjustsFontForContentSizeCategory = true
        dateLabel.textColor = .secondaryLabel
        dateLabel.numberOfLines = 1
        dateLabel.lineBreakMode = .byTruncatingTail

        favoriteImageView.image = UIImage(systemName: "heart.fill")
        favoriteImageView.tintColor = .systemRed
        favoriteImageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 14, weight: .semibold)
        favoriteImageView.isHidden = true

        textStack.axis = .vertical
        textStack.alignment = .fill
        textStack.spacing = 5
        textStack.translatesAutoresizingMaskIntoConstraints = false

        eyebrowStack.axis = .horizontal
        eyebrowStack.alignment = .firstBaseline
        eyebrowStack.spacing = 8
        eyebrowStack.distribution = .fill
        eyebrowStack.addArrangedSubview(categoryLabel)
        eyebrowStack.addArrangedSubview(dateLabel)

        textStack.addArrangedSubview(eyebrowStack)
        textStack.addArrangedSubview(titleLabel)
        textStack.addArrangedSubview(subtitleLabel)

        contentView.addSubview(imageContainerView)
        imageContainerView.addSubview(imageView)
        contentView.addSubview(textStack)
        contentView.addSubview(favoriteImageView)
        favoriteImageView.translatesAutoresizingMaskIntoConstraints = false

        textLeadingConstraint = textStack.leadingAnchor.constraint(equalTo: imageContainerView.trailingAnchor, constant: 12)
        accessibleTextLeadingConstraint = textStack.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12)
        let preferredImageWidth = imageContainerView.widthAnchor.constraint(equalToConstant: 118)
        preferredImageWidth.priority = .defaultHigh

        NSLayoutConstraint.activate([
            contentView.heightAnchor.constraint(greaterThanOrEqualToConstant: 138),
            imageContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            imageContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            imageContainerView.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -10),
            preferredImageWidth,
            imageContainerView.widthAnchor.constraint(lessThanOrEqualTo: contentView.widthAnchor, multiplier: 0.35),
            imageContainerView.widthAnchor.constraint(equalTo: imageContainerView.heightAnchor),

            imageView.leadingAnchor.constraint(equalTo: imageContainerView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: imageContainerView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: imageContainerView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: imageContainerView.bottomAnchor),

            textLeadingConstraint,
            textStack.trailingAnchor.constraint(equalTo: favoriteImageView.leadingAnchor, constant: -10),
            textStack.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            textStack.topAnchor.constraint(greaterThanOrEqualTo: contentView.topAnchor, constant: 12),
            textStack.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -12),

            favoriteImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12),
            favoriteImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            favoriteImageView.widthAnchor.constraint(equalToConstant: 18),
            favoriteImageView.heightAnchor.constraint(equalToConstant: 18),
        ])

        categoryLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        categoryLabel.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        dateLabel.setContentHuggingPriority(.defaultLow, for: .horizontal)
        dateLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        updateTextLayout()
        registerForTraitChanges([UITraitPreferredContentSizeCategory.self]) { (cell: EventSpotlightCell, _) in
            cell.updateTextLayout()
        }
    }

    private func updateTextLayout() {
        let usesVerticalText = traitCollection.preferredContentSizeCategory.isAccessibilityCategory
        imageContainerView.isHidden = usesVerticalText
        textLeadingConstraint.isActive = !usesVerticalText
        accessibleTextLeadingConstraint.isActive = usesVerticalText
        eyebrowStack.axis = usesVerticalText ? .vertical : .horizontal
        eyebrowStack.alignment = usesVerticalText ? .fill : .firstBaseline
        categoryLabel.numberOfLines = usesVerticalText ? 0 : 1
        dateLabel.numberOfLines = usesVerticalText ? 0 : 1
        titleLabel.numberOfLines = usesVerticalText ? 0 : 2
        subtitleLabel.numberOfLines = usesVerticalText ? 0 : 2
    }
    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}

}

#Preview("Event spotlight", traits: .fixedLayout(width: 350, height: 170)) {
    let cell = EventSpotlightCell()
    cell.configure(with: Event(
        id: 1,
        name: "Museum tour: art and local history",
        startDate: Date(),
        category: "Exhibition"
    ))
    return cell
}

#Preview("Event spotlight · Accessibility", traits: .fixedLayout(width: 350, height: 650)) {
    let cell = EventSpotlightCell()
    cell.traitOverrides.preferredContentSizeCategory = .accessibilityExtraExtraExtraLarge
    cell.configure(with: Event(
        id: 1,
        name: "Museum tour: art and local history",
        startDate: Date(),
        category: "Exhibition"
    ))
    return cell
}
