//
//  SettingsRowContentConfiguration.swift
//
//
//  Created by Codex on 04.04.26.
//

#if canImport(UIKit) && os(iOS)

import UIKit

public struct SettingsRowContentConfiguration: UIContentConfiguration, Hashable {

    public struct Icon: Hashable {
        public let symbolName: String
        public let symbolColor: UIColor
        public let backgroundColor: UIColor

        public init(symbolName: String, symbolColor: UIColor = .white, backgroundColor: UIColor) {
            self.symbolName = symbolName
            self.symbolColor = symbolColor
            self.backgroundColor = backgroundColor
        }
    }

    public var title: String
    public var subtitle: String?
    public var icon: Icon?

    public init(title: String, subtitle: String? = nil, icon: Icon? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
    }

    public func makeContentView() -> any UIView & UIContentView {
        SettingsRowContentView(configuration: self)
    }

    public func updated(for state: any UIConfigurationState) -> SettingsRowContentConfiguration {
        self
    }
}

private final class SettingsRowContentView: UIView, UIContentView {

    private let iconContainerView = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()
    private let labelsStackView = UIStackView()
    private let contentStackView = UIStackView()

    private var appliedConfiguration: SettingsRowContentConfiguration

    var configuration: UIContentConfiguration {
        get { appliedConfiguration }
        set {
            guard let newConfiguration = newValue as? SettingsRowContentConfiguration else { return }
            apply(configuration: newConfiguration)
        }
    }

    init(configuration: SettingsRowContentConfiguration) {
        self.appliedConfiguration = configuration
        super.init(frame: .zero)
        setupUI()
        apply(configuration: configuration)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setupUI() {
        backgroundColor = .clear
        directionalLayoutMargins = NSDirectionalEdgeInsets(top: 12, leading: 16, bottom: 12, trailing: 4)

        iconContainerView.translatesAutoresizingMaskIntoConstraints = false
        iconContainerView.layer.cornerRadius = 8
        iconContainerView.clipsToBounds = true

        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 16, weight: .semibold)

        titleLabel.font = .preferredFont(forTextStyle: .body)
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 1
        titleLabel.adjustsFontForContentSizeCategory = true

        subtitleLabel.font = .preferredFont(forTextStyle: .subheadline)
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 2
        subtitleLabel.adjustsFontForContentSizeCategory = true

        labelsStackView.axis = .vertical
        labelsStackView.alignment = .leading
        labelsStackView.spacing = 2
        labelsStackView.translatesAutoresizingMaskIntoConstraints = false

        contentStackView.axis = .horizontal
        contentStackView.alignment = .center
        contentStackView.spacing = 12
        contentStackView.translatesAutoresizingMaskIntoConstraints = false

        addSubview(contentStackView)
        iconContainerView.addSubview(iconImageView)
        labelsStackView.addArrangedSubview(titleLabel)
        labelsStackView.addArrangedSubview(subtitleLabel)
        contentStackView.addArrangedSubview(iconContainerView)
        contentStackView.addArrangedSubview(labelsStackView)

        NSLayoutConstraint.activate([
            contentStackView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            contentStackView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            contentStackView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            contentStackView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),

            iconContainerView.widthAnchor.constraint(equalToConstant: 30),
            iconContainerView.heightAnchor.constraint(equalToConstant: 30),

            iconImageView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor)
        ])
    }

    private func apply(configuration: SettingsRowContentConfiguration) {
        appliedConfiguration = configuration

        titleLabel.text = configuration.title

        if let subtitle = configuration.subtitle, !subtitle.isEmpty {
            subtitleLabel.text = subtitle
            subtitleLabel.isHidden = false
        } else {
            subtitleLabel.text = nil
            subtitleLabel.isHidden = true
        }

        if let icon = configuration.icon {
            iconContainerView.isHidden = false
            iconContainerView.backgroundColor = icon.backgroundColor
            iconImageView.tintColor = icon.symbolColor
            iconImageView.image = UIImage(systemName: icon.symbolName)
        } else {
            iconContainerView.isHidden = true
            iconImageView.image = nil
        }
    }
}

#endif
