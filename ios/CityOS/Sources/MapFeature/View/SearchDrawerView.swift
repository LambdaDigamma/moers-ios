import UIKit

public final class SearchDrawerView: UIView {
    
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
        collectionView.backgroundColor = .clear
        collectionView.keyboardDismissMode = .interactive
        keyboardLayoutGuide.usesBottomSafeArea = false
        
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: topAnchor),
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
