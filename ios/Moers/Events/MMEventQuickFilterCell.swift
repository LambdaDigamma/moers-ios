//
//  MMEventQuickFilterCell.swift
//  Moers
//
//  Created by Codex on 28.06.26.
//

import UIKit

final class MMEventQuickFilterCell: UICollectionViewCell {
    static let reuseIdentifier = "MMEventQuickFilterCell"

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

    func configure(with filter: MMEventQuickFilter, isSelected: Bool) {
        symbolView.image = UIImage(systemName: filter.systemImageName)
        titleLabel.text = filter.title
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
