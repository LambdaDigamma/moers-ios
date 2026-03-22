//
//  SidebarViewController.swift
//  
//
//  Created by Lennart Fischer on 31.03.22.
//

#if canImport(UIKit) && !os(tvOS) && os(iOS)
import UIKit
import Combine

public extension Notification.Name {
    
    static let reloadSidebar = Notification.Name(rawValue: "reloadSidebar")
    
}

@available(iOS 14.0, *)
public protocol SidebarViewControllerDelegate: AnyObject {
    
    func sidebar(_ sidebarViewController: SidebarViewController, didSelectTabItem item: SidebarItem)
    
}

public typealias SectionItemProducer = (SidebarSection) -> [SidebarItem]

@available(iOS 14.0, *)
open class SidebarViewController: UIViewController, UICollectionViewDelegate {
    
    public weak var delegate: SidebarViewControllerDelegate?
    
    public var sidebarTitle: String? {
        didSet {
            self.navigationItem.title = sidebarTitle
        }
    }
    
    public var sections: [SidebarSection] = [] {
        didSet {
            self.applyCurrentSnapshot()
        }
    }
    
    public var tabs: [SidebarItem] = [] {
        didSet {
            self.applyCurrentSnapshot()
        }
    }
    
    public var sectionItemProducer: SectionItemProducer?
    
    private lazy var collectionView: UICollectionView = {
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: buildCollectionViewLayout())
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.delegate = self
        return collectionView
    }()
    
    private lazy var dataSource: UICollectionViewDiffableDataSource<SidebarSection, SidebarItem> = {
        return configureDataSource()
    }()
    
    private var cancellables = Set<AnyCancellable>()
    
    private var currentSidebarItems: [[SidebarItem]] = []
    
    // MARK: - Initializers -
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController Lifecycle -
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.applyCurrentSnapshot()
        self.setupListeners()
        
        if let firstSection = sections.first {
            if let sectionItemProducer = sectionItemProducer,
                !sectionItemProducer(firstSection).isEmpty {
                self.collectionView.selectItem(
                    at: IndexPath(item: 0, section: 0),
                    animated: false,
                    scrollPosition: .centeredVertically
                )
            }
        }
        
    }
    
    // MARK: - Setup UI -
    
    open func setupUI() {
        
        self.navigationController?.navigationBar.prefersLargeTitles = true
        
        self.view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.topAnchor.constraint(equalTo: view.topAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
    }
    
    open func setupListeners() {
        
        NotificationCenter.default.publisher(for: .reloadSidebar)
            .sink { (_: Notification) in
                // ToDo: Update sidebar here
            }
            .store(in: &cancellables)
        
    }
    
    open func buildCollectionViewLayout() -> UICollectionViewLayout {
        
        return UICollectionViewCompositionalLayout { section, layoutEnvironment in
            var config = UICollectionLayoutListConfiguration(appearance: .sidebar)
            config.headerMode = section == 0 ? .none : .firstItemInSection
            return NSCollectionLayoutSection.list(using: config, layoutEnvironment: layoutEnvironment)
        }
        
    }
    
    open func configureDataSource() -> UICollectionViewDiffableDataSource<SidebarSection, SidebarItem> {
        
        let headerRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, SidebarItem> { (cell, _, item) in
            var content = cell.defaultContentConfiguration()
            content.text = item.title
            cell.contentConfiguration = content
            cell.accessories = [.outlineDisclosure()]
        }
        
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewListCell, SidebarItem> { (cell, _, item) in
            var content = cell.defaultContentConfiguration()
            content.text = item.title
            content.image = item.image?.withTintColor(UIColor.systemYellow)
            content.imageProperties.tintColor = UIColor.systemYellow
            cell.accessibilityIdentifier = item.accessibilityIdentifier
            cell.accessibilityTraits = [.button]
            cell.contentConfiguration = content
            cell.accessories = []
            
            var background = UIBackgroundConfiguration.listSidebarCell()
            background.backgroundColorTransformer = UIConfigurationColorTransformer { [weak cell] _ in
                guard let state = cell?.configurationState else { return .clear }
                return state.isSelected || state.isHighlighted ? UIColor.tertiarySystemBackground : .clear
            }
            
            cell.backgroundConfiguration = background
            
        }
        
        return UICollectionViewDiffableDataSource<SidebarSection, SidebarItem>(collectionView: collectionView) {
            (collectionView: UICollectionView, indexPath: IndexPath, item: SidebarItem) -> UICollectionViewCell? in
            if indexPath.item == 0 && indexPath.section != 0 {
                return collectionView.dequeueConfiguredReusableCell(using: headerRegistration, for: indexPath, item: item)
            } else {
                return collectionView.dequeueConfiguredReusableCell(using: cellRegistration, for: indexPath, item: item)
            }
        }
        
    }
    
    open func applyCurrentSnapshot() {
        
        var snapshot = NSDiffableDataSourceSnapshot<SidebarSection, SidebarItem>()
        snapshot.appendSections(sections)
        dataSource.apply(snapshot, animatingDifferences: false)
        
        guard let sectionItemProducer = sectionItemProducer else {
            return
        }
        
        self.currentSidebarItems = []
        
        for section in sections {
            
            var sectionSnapshot = NSDiffableDataSourceSectionSnapshot<SidebarItem>()
            
            var localItems: [SidebarItem] = []
            
            if let sectionTitle = section.title {
                
                let headerItem = SidebarItem(title: sectionTitle)
                sectionSnapshot.append([headerItem])
                sectionSnapshot.expand([headerItem])
                localItems.append(headerItem)
                
            }
            
            let items = sectionItemProducer(section)
            sectionSnapshot.append(items)
            dataSource.apply(sectionSnapshot, to: section)
            localItems.append(contentsOf: items)
            
            self.currentSidebarItems.append(localItems)
            
        }
        
    }
    
    public func selectIndex(_ index: Int) {
        if viewIfLoaded != nil {
            self.collectionView.selectItem(at: IndexPath(item: index, section: 0), animated: false, scrollPosition: .top)
        }
    }
    
    open func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        if let section = currentSidebarItems[safe: indexPath.section], let item = section[safe: indexPath.row] {
            
            delegate?.sidebar(self, didSelectTabItem: item)
            
        }
        
    }
    
}

#endif
