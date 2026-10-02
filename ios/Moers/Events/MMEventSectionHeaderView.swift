//
//  MMEventSectionHeaderView.swift
//  Moers
//
//  Created by Codex on 28.06.26.
//

import UIKit

final class MMEventSectionHeaderView: UICollectionReusableView {
    static let reuseIdentifier = "MMEventSectionHeaderView"

    private let titleLabel = UILabel()
    private let countLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        titleLabel.text = nil
        countLabel.text = nil
    }

    func configure(title: String, count: Int) {
        titleLabel.text = title
        countLabel.text = count > 0 ? "\(count)" : nil
    }

    private func setup() {
        titleLabel.font = UIFont.mmEventPreferredFont(forTextStyle: .headline, weight: .semibold)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textColor = .label

        countLabel.font = UIFont.mmEventPreferredFont(forTextStyle: .footnote, weight: .semibold)
        countLabel.adjustsFontForContentSizeCategory = true
        countLabel.textColor = .secondaryLabel
        countLabel.textAlignment = .right

        let stackView = UIStackView(arrangedSubviews: [titleLabel, countLabel])
        stackView.axis = .horizontal
        stackView.alignment = .lastBaseline
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -6),
        ])
    }
    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}

}
