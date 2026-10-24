//
//  TimetableTopAccessoryView.swift
//
//
//  Created by Claude on 24.10.26.
//

#if !os(tvOS)

import UIKit

/// Hosted in the navigation bar's palette: an optional "filter active" banner above the day bubbles.
final class TimetableTopAccessoryView: UIView {

    let bubbleView = TimetableDayBubbleView()
    var onClearFilter: (() -> Void)?

    private let stackView = UIStackView()
    private let filterBanner = UIStackView()

    nonisolated deinit {}

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupFilterBanner()
        setupStackView()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setFilterActive(_ isActive: Bool) {
        filterBanner.isHidden = !isActive
    }

    // MARK: - Setup

    private func setupFilterBanner() {
        let imageView = UIImageView(image: UIImage(systemName: "line.3.horizontal.decrease.circle.fill"))
        imageView.tintColor = tintColor
        imageView.setContentHuggingPriority(.required, for: .horizontal)

        let label = UILabel()
        label.text = EventPackageStrings.filterActive
        label.font = .preferredFont(forTextStyle: .subheadline)
        label.textColor = .secondaryLabel
        label.adjustsFontForContentSizeCategory = true
        label.numberOfLines = 0

        var configuration = UIButton.Configuration.plain()
        configuration.title = EventPackageStrings.clearFilter
        configuration.contentInsets = NSDirectionalEdgeInsets(top: 8, leading: 8, bottom: 8, trailing: 0)
        configuration.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { container in
            var container = container
            container.font = UIFontMetrics(forTextStyle: .subheadline)
                .scaledFont(for: .systemFont(ofSize: 15, weight: .bold))
            return container
        }
        let clearButton = UIButton(configuration: configuration, primaryAction: UIAction { [weak self] _ in
            self?.onClearFilter?()
        })
        clearButton.setContentHuggingPriority(.required, for: .horizontal)
        clearButton.setContentCompressionResistancePriority(.required, for: .horizontal)

        filterBanner.axis = .horizontal
        filterBanner.alignment = .center
        filterBanner.spacing = 8
        filterBanner.isLayoutMarginsRelativeArrangement = true
        filterBanner.layoutMargins = UIEdgeInsets(top: 4, left: 16, bottom: 0, right: 16)
        filterBanner.addArrangedSubview(imageView)
        filterBanner.addArrangedSubview(label)
        filterBanner.addArrangedSubview(clearButton)
        filterBanner.isHidden = true
    }

    private func setupStackView() {
        stackView.axis = .vertical
        stackView.addArrangedSubview(filterBanner)
        stackView.addArrangedSubview(bubbleView)
        stackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(stackView)

        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.leadingAnchor.constraint(equalTo: leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }

}

#endif
