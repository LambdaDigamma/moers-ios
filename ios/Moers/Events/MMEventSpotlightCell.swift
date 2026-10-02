//
//  MMEventSpotlightCell.swift
//  Moers
//
//  Created by Codex on 28.06.26.
//

import UIKit
import MMEvents

final class MMEventSpotlightCell: UICollectionViewCell {
    static let reuseIdentifier = "MMEventSpotlightCell"

    private let imageView = MMEventAsyncImageView()
    private let imageContainerView = UIView()
    private let categoryLabel = UILabel()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let favoriteImageView = UIImageView()
    private let dateLabel = UILabel()
    private let textStack = UIStackView()

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

    func configure(with event: Event) {
        imageView.setImage(url: event.image)
        let categoryText = event.category ?? (event.attendanceMode.flatMap { MMEventAttendanceMode(rawValue: $0)?.title })
        categoryLabel.text = categoryText
        categoryLabel.isHidden = categoryLabel.text == nil
        titleLabel.text = event.name
        subtitleLabel.text = MMEventFormatter.subtitle(for: event)
        dateLabel.text = MMEventFormatter.compactDate(for: event)
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

        let eyebrowStack = UIStackView(arrangedSubviews: [categoryLabel, dateLabel])
        eyebrowStack.axis = .horizontal
        eyebrowStack.alignment = .firstBaseline
        eyebrowStack.spacing = 8
        eyebrowStack.distribution = .fill

        textStack.addArrangedSubview(eyebrowStack)
        textStack.addArrangedSubview(titleLabel)
        textStack.addArrangedSubview(subtitleLabel)

        contentView.addSubview(imageContainerView)
        imageContainerView.addSubview(imageView)
        contentView.addSubview(textStack)
        contentView.addSubview(favoriteImageView)
        favoriteImageView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            imageContainerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            imageContainerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            imageContainerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10),
            imageContainerView.widthAnchor.constraint(equalTo: imageContainerView.heightAnchor),

            imageView.leadingAnchor.constraint(equalTo: imageContainerView.leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: imageContainerView.trailingAnchor),
            imageView.topAnchor.constraint(equalTo: imageContainerView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: imageContainerView.bottomAnchor),

            textStack.leadingAnchor.constraint(equalTo: imageContainerView.trailingAnchor, constant: 12),
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
    }
    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}

}
