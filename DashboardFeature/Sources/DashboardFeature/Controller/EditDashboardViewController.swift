//
//  EditDashboardViewController.swift
//  
//
//  Created by Lennart Fischer on 15.12.22.
//

import UIKit

public struct DashboardConfigurationItem: Identifiable, Hashable {
    
    public let id = UUID()
    
    public let title: String
    public let subtitle: String
    
    public init(title: String, subtitle: String) {
        self.title = title
        self.subtitle = subtitle
    }
    
}

public class EditDashboardViewController: UIViewController {

    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(
            frame: .zero,
            collectionViewLayout: Self.configureLayout()
        )
        return view
    }()
    
    enum Section: Int, CaseIterable, Hashable {
        case enabled
    }
    
    typealias DataSource = UICollectionViewDiffableDataSource<Section, DashboardConfigurationItem>
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.setupConstraints()
        
    }
    
    // MARK: - UI -
    
    private func setupUI() {
        
        self.title = "Edit dashboard"
        
        self.view.addSubview(collectionView)
        
//        self.addSubSwiftUIView(EditDashboardView(), to: view)
        
        self.view.backgroundColor = UIColor.systemBackground
        
        
    }
    
    private func setupConstraints() {
        
        let constraints = [
            collectionView.topAnchor.constraint(equalTo: self.view.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    static func configureLayout() -> UICollectionViewLayout {
        
        let configuration = UICollectionLayoutListConfiguration(appearance: .grouped)
        
        return UICollectionViewCompositionalLayout.list(using: configuration)
        
    }
    
    // MARK: - Collection -
    
    func makeDataSource() -> DataSource {
        return DataSource(collectionView: collectionView) { collectionView, indexPath, item -> UICollectionViewCell? in
            return collectionView.dequeueConfiguredReusableCell(
                using: self.categoryCellregistration(),
                for: indexPath,
                item: item
            )
        }
    }
    
    func categoryCellregistration() -> UICollectionView.CellRegistration<UICollectionViewListCell, DashboardConfigurationItem> {
        return .init { cell, _, item in
            var configuration = cell.defaultContentConfiguration()
            configuration.text = item.title
            cell.contentConfiguration = configuration
        }
    }
    
}
