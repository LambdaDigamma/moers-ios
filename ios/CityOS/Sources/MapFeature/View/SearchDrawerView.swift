import UIKit

public final class SearchDrawerView: UIView {
    let searchBar = UISearchBar()
    let collectionView: UICollectionView

    init() {
        
        var configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        configuration.headerMode = .supplementary
        collectionView = UICollectionView(
            frame: .zero,
            collectionViewLayout: UICollectionViewCompositionalLayout.list(using: configuration)
        )
        
        super.init(frame: .zero)
        
        backgroundColor = .systemGroupedBackground
        searchBar.searchBarStyle = .minimal
        searchBar.placeholder = String(localized: "Where do you want to go?", bundle: .module)
        searchBar.accessibilityIdentifier = "SearchBar"
        searchBar.searchTextField.adjustsFontForContentSizeCategory = true
        searchBar.searchTextField.allowsDeletingTokens = true
        searchBar.searchTextField.allowsCopyingTokens = false
        collectionView.backgroundColor = .clear
        collectionView.keyboardDismissMode = .interactive
        
        for subview in [searchBar, collectionView] {
            subview.translatesAutoresizingMaskIntoConstraints = false
            addSubview(subview)
        }
        
        NSLayoutConstraint.activate([
            searchBar.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 8),
            searchBar.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -8),
            searchBar.heightAnchor.constraint(greaterThanOrEqualToConstant: 56),
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 8),
            collectionView.leadingAnchor.constraint(equalTo: leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: keyboardLayoutGuide.topAnchor)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    nonisolated deinit {}
}
