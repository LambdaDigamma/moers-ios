import Core
import UIKit
import SwiftUI

final class SelectionViewController: UIViewController {
    weak var container: MapContainerViewController?
    private var dataSource: UICollectionViewDiffableDataSource<Int, Core.AnyLocation>!
    private var locationsByID: [Core.AnyLocation: Location] = [:]
    private lazy var collectionView: UICollectionView = {
        let configuration = UICollectionLayoutListConfiguration(appearance: .insetGrouped)
        let layout = UICollectionViewCompositionalLayout.list(using: configuration)
        let view = UICollectionView(frame: .zero, collectionViewLayout: layout)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.delegate = self
        return view
    }()

    var clusteredLocations: [Location] = [] {
        didSet {
            title = String(localized: "\(clusteredLocations.count) Entries", bundle: .module)
            if isViewLoaded { updateSnapshot() }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        view.addSubview(collectionView)
        NSLayoutConstraint.activate([
            collectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        configureDataSource()
        registerForTraitChanges([UITraitUserInterfaceStyle.self]) { (controller: SelectionViewController, _) in
            controller.dataSource.applySnapshotUsingReloadData(controller.dataSource.snapshot())
        }
        updateSnapshot()
    }

    private func configureDataSource() {
        let registration = UICollectionView.CellRegistration<UICollectionViewListCell, Core.AnyLocation> {
            [weak self] cell, _, identifier in
            guard let self, let location = locationsByID[identifier] else { return }
            cell.contentConfiguration = UIProperties.listContent(for: location)
            cell.accessories = [.disclosureIndicator()]
        }
        dataSource = UICollectionViewDiffableDataSource<Int, Core.AnyLocation>(collectionView: collectionView) {
            collectionView, indexPath, identifier in
            collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: identifier)
        }
    }

    private func updateSnapshot() {
        locationsByID.removeAll(keepingCapacity: true)
        var snapshot = NSDiffableDataSourceSnapshot<Int, Core.AnyLocation>()
        snapshot.appendSections([0])
        let identifiers = clusteredLocations.map { location in
            let identifier = Core.AnyLocation(location)
            locationsByID[identifier] = location
            return identifier
        }
        snapshot.appendItems(identifiers)
        let previousItems = Set(dataSource.snapshot().itemIdentifiers)
        snapshot.reconfigureItems(identifiers.filter { previousItems.contains($0) })
        dataSource.apply(snapshot, animatingDifferences: false)
    }

    nonisolated deinit {}
}

extension SelectionViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        guard let identifier = dataSource.itemIdentifier(for: indexPath),
              let location = locationsByID[identifier] else { return }
        container?.showLocation(location, fromList: true)
    }
}

#Preview {
    let controller = SelectionViewController()
    controller.clusteredLocations = [Camera.stub(withID: 1), Camera.stub(withID: 2)]
    return UINavigationController(rootViewController: controller)
}
