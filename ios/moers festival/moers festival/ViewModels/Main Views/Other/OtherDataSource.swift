//
//  OtherDataSource.swift
//  moers festival
//
//  Created by Lennart Fischer on 15.04.19.
//  Copyright © 2019 CodeForNiederrhein. All rights reserved.
//

import UIKit
import AppScaffold

nonisolated private enum OtherCollectionSection: Hashable, Sendable {
    case hero
    case group(Section)
}

nonisolated private enum OtherCollectionItem: Hashable, Sendable {
    case hero(OtherHeroContent)
    case row(Row)
}

@MainActor
class OtherDataSource: NSObject {
    
    // MARK: - Properties
    
    private let viewModel: OtherViewModel
    private var dataSource: UICollectionViewDiffableDataSource<OtherCollectionSection, OtherCollectionItem>?
    
    public init(viewModel: OtherViewModel) {
        self.viewModel = viewModel
        super.init()
    }
    
    // MARK: - Setup
    
    public func setupDataSource(collectionView: UICollectionView) {
        
        let heroCellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, OtherHeroContent> { cell, _, hero in
            cell.contentConfiguration = FestivalInfoHeroContentConfiguration(
                title: hero.title,
                subtitle: hero.subtitle,
                icon: SettingsRowContentConfiguration.Icon(
                    symbolName: hero.symbolName,
                    backgroundColor: hero.iconStyle.backgroundColor
                )
            )
            cell.accessories = []
            cell.backgroundConfiguration = .clear()
            cell.separatorLayoutGuide.leadingAnchor.constraint(
                equalTo: cell.contentView.leadingAnchor,
                constant: cell.contentView.bounds.width
            ).isActive = true
        }

        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, Row> { cell, indexPath, row in
            let icon = row.symbolName.flatMap { symbolName in
                row.iconStyle.map {
                    SettingsRowContentConfiguration.Icon(
                        symbolName: symbolName,
                        backgroundColor: $0.backgroundColor
                    )
                }
            }

            cell.contentConfiguration = SettingsRowContentConfiguration(
                title: row.title,
                icon: icon
            )
            cell.accessories = row.style == .hero ? [] : [.disclosureIndicator()]
            cell.accessibilityIdentifier = "InfoCell-\(row.title.replacingOccurrences(of: " ", with: "_"))"
            let separatorInset: CGFloat = row.symbolName == nil ? 16 : 58
            cell.separatorLayoutGuide.leadingAnchor.constraint(
                equalTo: cell.contentView.leadingAnchor,
                constant: separatorInset
            ).isActive = true
        }
        
        let headerRegistration = UICollectionView.SupplementaryRegistration<UICollectionViewListCell>(elementKind: UICollectionView.elementKindSectionHeader) { [weak self] supplementaryView, string, indexPath in
            guard let self = self else { return }
            let section = self.dataSource?.snapshot().sectionIdentifiers[indexPath.section]
            guard case .group(let groupedSection) = section else {
                supplementaryView.contentConfiguration = nil
                supplementaryView.backgroundConfiguration = .clear()
                return
            }
            var content = supplementaryView.defaultContentConfiguration()
            content.text = groupedSection.title
            supplementaryView.contentConfiguration = content
            supplementaryView.backgroundConfiguration = .clear()
        }
        
        dataSource = UICollectionViewDiffableDataSource<OtherCollectionSection, OtherCollectionItem>(collectionView: collectionView) { (collectionView: UICollectionView, indexPath: IndexPath, item: OtherCollectionItem) -> UICollectionViewCell? in
            switch item {
            case .hero(let hero):
                return collectionView.dequeueConfiguredReusableCell(using: heroCellRegistration, for: indexPath, item: hero)
            case .row(let row):
                return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: row)
            }
        }
        
        dataSource?.supplementaryViewProvider = { (collectionView: UICollectionView, kind: String, indexPath: IndexPath) -> UICollectionReusableView? in
            return collectionView.dequeueConfiguredReusableSupplementary(using: headerRegistration, for: indexPath)
        }
        
        update()
    }
    
    public func update() {
        
        var snapshot = NSDiffableDataSourceSnapshot<OtherCollectionSection, OtherCollectionItem>()
        let heroSection = OtherCollectionSection.hero
        let heroItem = OtherCollectionItem.hero(viewModel.hero)

        snapshot.appendSections([heroSection])
        snapshot.appendItems([heroItem], toSection: heroSection)

        for section in viewModel.sections {
            let collectionSection = OtherCollectionSection.group(section)
            snapshot.appendSections([collectionSection])
            snapshot.appendItems(section.rows.map(OtherCollectionItem.row), toSection: collectionSection)
        }
        
        dataSource?.apply(snapshot, animatingDifferences: false)
        
    }
    
    public func itemIdentifier(for indexPath: IndexPath) -> Row? {
        guard case .row(let row) = dataSource?.itemIdentifier(for: indexPath) else {
            return nil
        }
        return row
    }
    
}

private struct FestivalInfoHeroContentConfiguration: UIContentConfiguration {
    let title: String
    let subtitle: String
    let icon: SettingsRowContentConfiguration.Icon

    func makeContentView() -> any UIView & UIContentView {
        FestivalInfoHeroContentView(configuration: self)
    }

    func updated(for state: any UIConfigurationState) -> FestivalInfoHeroContentConfiguration {
        self
    }
}

private final class FestivalInfoHeroContentView: UIView, UIContentView {

    private let cardView = UIView()
    private let iconContainerView = UIView()
    private let iconImageView = UIImageView()
    private let titleLabel = UILabel()
    private let subtitleLabel = UILabel()

    private var appliedConfiguration: FestivalInfoHeroContentConfiguration

    var configuration: UIContentConfiguration {
        get { appliedConfiguration }
        set {
            guard let newConfiguration = newValue as? FestivalInfoHeroContentConfiguration else { return }
            apply(configuration: newConfiguration)
        }
    }

    init(configuration: FestivalInfoHeroContentConfiguration) {
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
        directionalLayoutMargins = NSDirectionalEdgeInsets(top: 0, leading: 0, bottom: 8, trailing: 0)

        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .secondarySystemBackground
        cardView.layer.cornerRadius = 22
        cardView.layer.cornerCurve = .continuous

        iconContainerView.translatesAutoresizingMaskIntoConstraints = false
        iconContainerView.layer.cornerRadius = 18
        iconContainerView.layer.cornerCurve = .continuous

        iconImageView.translatesAutoresizingMaskIntoConstraints = false
        iconImageView.tintColor = .white
        iconImageView.preferredSymbolConfiguration = UIImage.SymbolConfiguration(pointSize: 28, weight: .semibold)

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .boldSystemFont(ofSize: UIFont.preferredFont(forTextStyle: .title2).pointSize)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 0

        subtitleLabel.translatesAutoresizingMaskIntoConstraints = false
        subtitleLabel.font = .preferredFont(forTextStyle: .body)
        subtitleLabel.adjustsFontForContentSizeCategory = true
        subtitleLabel.textColor = .secondaryLabel
        subtitleLabel.numberOfLines = 0

        addSubview(cardView)
        cardView.addSubview(iconContainerView)
        iconContainerView.addSubview(iconImageView)
        cardView.addSubview(titleLabel)
        cardView.addSubview(subtitleLabel)

        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: layoutMarginsGuide.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: layoutMarginsGuide.trailingAnchor),
            cardView.topAnchor.constraint(equalTo: layoutMarginsGuide.topAnchor),
            cardView.bottomAnchor.constraint(equalTo: layoutMarginsGuide.bottomAnchor),

            iconContainerView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            iconContainerView.topAnchor.constraint(equalTo: cardView.topAnchor, constant: 24),
            iconContainerView.widthAnchor.constraint(equalToConstant: 56),
            iconContainerView.heightAnchor.constraint(equalToConstant: 56),

            iconImageView.centerXAnchor.constraint(equalTo: iconContainerView.centerXAnchor),
            iconImageView.centerYAnchor.constraint(equalTo: iconContainerView.centerYAnchor),

            titleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            titleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),
            titleLabel.topAnchor.constraint(equalTo: iconContainerView.bottomAnchor, constant: 16),

            subtitleLabel.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 24),
            subtitleLabel.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -24),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -24)
        ])
    }

    private func apply(configuration: FestivalInfoHeroContentConfiguration) {
        appliedConfiguration = configuration
        titleLabel.text = configuration.title
        subtitleLabel.text = configuration.subtitle
        iconContainerView.backgroundColor = configuration.icon.backgroundColor
        iconImageView.image = UIImage(systemName: configuration.icon.symbolName)
    }
}

private extension RowIconStyle {

    var backgroundColor: UIColor {
        switch self {
        case .blue:
            return .systemBlue
        case .indigo:
            return .systemIndigo
        case .purple:
            return .systemPurple
        case .pink:
            return .systemPink
        case .red:
            return .systemRed
        case .orange:
            return .systemOrange
        case .yellow:
            return .systemYellow
        case .green:
            return .systemGreen
        case .mint:
            return .systemMint
        case .teal:
            return .systemTeal
        case .cyan:
            return .systemCyan
        case .gray:
            return .systemGray
        }
    }
}
