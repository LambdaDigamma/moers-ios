//
//  MMEventEmptyCell.swift
//  Moers
//
//  Created by Codex on 28.06.26.
//

import UIKit

final class MMEventEmptyCell: UICollectionViewCell {
    static let reuseIdentifier = "MMEventEmptyCell"

    private let imageView = UIImageView()
    private let titleLabel = UILabel()
    private let messageLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String, message: String) {
        titleLabel.text = title
        messageLabel.text = message
    }

    private func setup() {
        contentView.backgroundColor = .secondarySystemGroupedBackground
        contentView.layer.cornerRadius = 16
        contentView.layer.cornerCurve = .continuous

        imageView.image = UIImage(systemName: "calendar.badge.exclamationmark")
        imageView.tintColor = .secondaryLabel
        imageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 28, weight: .regular)

        titleLabel.font = UIFont.mmEventPreferredFont(forTextStyle: .headline, weight: .semibold)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center

        messageLabel.font = UIFont.preferredFont(forTextStyle: .subheadline)
        messageLabel.adjustsFontForContentSizeCategory = true
        messageLabel.textColor = .secondaryLabel
        messageLabel.numberOfLines = 0
        messageLabel.textAlignment = .center

        let stackView = UIStackView(arrangedSubviews: [imageView, titleLabel, messageLabel])
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 10
        stackView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 24),
            stackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -24),
            stackView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
        ])
    }
    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}

}
