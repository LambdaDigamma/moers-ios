//
//  MapContainerViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 15.04.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Core
import UIKit
import SwiftUI
import CoreLocation
import FactoryKit
import FuelFeature

public class MapContainerViewController: UISplitViewController {

    @LazyInjected(\.entryManager) var entryManager
    @LazyInjected(\.petrolService) var petrolManager
    @LazyInjected(\.cameraManager) var cameraManager
    
    public weak var coordinator: MapCoordintor?
    
    public let mapViewController: MapViewController
    public let searchViewController: SearchDrawerViewController
    public var locations: [Location] = []
    private(set) weak var selectedLocation: Location?
    let panelNavigationController: UINavigationController
    private let sheetTransitioningDelegate = MapSheetTransitioningDelegate()
    var sidebarController: UISplitViewController? { showsSidebar ? self : nil }
    private var showsSidebar = false
    private let compactMapNavigationController: UINavigationController
    private let sidebarMapNavigationController: UINavigationController
    private var wantsPanelVisible = false
    private var isPresentingPanel = false
    private var isDismissingPanel = false
    private var pendingSearchFocus = false
    private var suspensionCompletions: [() -> Void] = []

    public init(
        mapViewController: MapViewController = MapViewController(),
        searchViewController: SearchDrawerViewController = SearchDrawerViewController(),
        panelNavigationController: UINavigationController? = nil
    ) {
        self.mapViewController = mapViewController
        self.searchViewController = searchViewController
        self.panelNavigationController = panelNavigationController ?? UINavigationController()
        compactMapNavigationController = UINavigationController(rootViewController: mapViewController)
        sidebarMapNavigationController = UINavigationController()
        super.init(style: .doubleColumn)
        preferredDisplayMode = .oneBesideSecondary
        preferredSplitBehavior = .tile
        minimumPrimaryColumnWidth = 280
        maximumPrimaryColumnWidth = 400
        preferredPrimaryColumnWidthFraction = 0.32
        displayModeButtonVisibility = .never
        compactMapNavigationController.setNavigationBarHidden(true, animated: false)
        sidebarMapNavigationController.setNavigationBarHidden(true, animated: false)
        setViewController(compactMapNavigationController, for: .compact)
        setViewController(sidebarMapNavigationController, for: .secondary)
        mapViewController.container = self
        searchViewController.container = self
        self.panelNavigationController.setViewControllers([searchViewController], animated: false)
        self.panelNavigationController.delegate = self
        self.panelNavigationController.navigationBar.prefersLargeTitles = false
        self.panelNavigationController.isModalInPresentation = true
        self.panelNavigationController.modalPresentationStyle = .custom
        self.panelNavigationController.transitioningDelegate = sheetTransitioningDelegate
        sheetTransitioningDelegate.sheetDelegate = self
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = AppStrings.Menu.map
        navigationItem.largeTitleDisplayMode = .never
        definesPresentationContext = true
        view.backgroundColor = .systemBackground
        panelNavigationController.setNavigationBarHidden(true, animated: false)
        registerForTraitChanges([UITraitHorizontalSizeClass.self]) { (controller: MapContainerViewController, _) in
            controller.updatePanelPresentation()
        }
        loadData()
    }

    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.setNavigationBarHidden(true, animated: animated)
        resumePanelPresentation()
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        resumePanelPresentation()
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        let hasLeftNavigation = navigationController.map { $0.topViewController !== self } ?? false
        let hasLeftTab = tabBarController.map { $0.selectedViewController !== (navigationController ?? self) } ?? false
        if hasLeftNavigation || hasLeftTab {
            suspendPanelPresentation()
        }
    }

    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        updatePanelPresentation()
    }

    public func showSearch(focusSearch: Bool = false, animated: Bool = true) {
        pendingSearchFocus = focusSearch
        if !focusSearch { searchViewController.searchDrawer.searchBar.resignFirstResponder() }
        clearMapSelection()
        showPanel(searchViewController, detent: focusSearch ? .large : MapSheetPresentationController.compactDetent,
                  animated: animated)
        focusSearchIfNeeded()
    }

    func showLocation(_ location: Location, fromList: Bool = false, animated: Bool = true) {
        if selectedLocation === location,
           let detail = panelNavigationController.topViewController as? DetailViewController,
           detail.selectedLocation === location { return }
        pendingSearchFocus = false
        let detail = DetailViewController()
        detail.coordinator = coordinator
        detail.selectedLocation = location
        showPanel(detail, push: fromList, animated: animated)
        selectedLocation = location
        mapViewController.selectLocation(location, animated: animated)
    }

    func showCluster(_ locations: [Location], animated: Bool = true) {
        pendingSearchFocus = false
        clearMapSelection()
        let selection = SelectionViewController()
        selection.container = self
        selection.clusteredLocations = locations
        showPanel(selection, animated: animated)
    }

    private func showPanel(
        _ controller: UIViewController,
        push: Bool = false,
        detent: UISheetPresentationController.Detent.Identifier = .medium,
        animated: Bool = true
    ) {
        if controller === searchViewController {
            panelNavigationController.setViewControllers([controller], animated: animated)
        } else {
            panelNavigationController.viewIfLoaded?.endEditing(true)
            controller.navigationItem.rightBarButtonItem = UIBarButtonItem(
                barButtonSystemItem: .close, target: self, action: #selector(closePanel)
            )
            controller.navigationItem.rightBarButtonItem?.accessibilityIdentifier = "MapSheetCloseButton"
            if push {
                panelNavigationController.pushViewController(controller, animated: animated)
            } else {
                panelNavigationController.setViewControllers([searchViewController, controller], animated: animated)
            }
        }
        sheetTransitioningDelegate.selectedDetentIdentifier = detent
        if let sheet = panelNavigationController.presentationController as? UISheetPresentationController {
            sheet.animateChanges { sheet.selectedDetentIdentifier = detent }
        }
        resumePanelPresentation()
    }

    @objc private func closePanel() {
        showSearch()
    }

    public func resumePanelPresentation() {
        wantsPanelVisible = true
        updatePanelPresentation()
    }

    public func suspendPanelPresentation(completion: (() -> Void)? = nil) {
        wantsPanelVisible = false
        pendingSearchFocus = false
        panelNavigationController.viewIfLoaded?.endEditing(true)
        if let completion { suspensionCompletions.append(completion) }
        updatePanelPresentation()
    }

    private func updatePanelPresentation() {
        guard isViewLoaded else {
            finishSuspension()
            return
        }
        guard !isPresentingPanel, !isDismissingPanel else { return }
        let isSelectedTab = tabBarController.map { $0.selectedViewController === (navigationController ?? self) } ?? true
        guard wantsPanelVisible, isSelectedTab else {
            if panelNavigationController.presentingViewController != nil {
                dismissPresentedPanel()
            } else {
                finishSuspension()
            }
            return
        }
        let needsSidebar = traitCollection.horizontalSizeClass == .regular
        if needsSidebar {
            if panelNavigationController.presentingViewController != nil {
                dismissPresentedPanel()
            } else if sidebarController == nil {
                attachSidebar()
            }
        } else {
            if sidebarController != nil { detachSidebar() }
            presentSheetIfNeeded()
        }
    }

    private func presentSheetIfNeeded() {
        updateSheetBottomInset()
        guard view.window != nil, panelNavigationController.presentingViewController == nil,
              presentedViewController == nil else { return }
        let isCompact = sheetTransitioningDelegate.selectedDetentIdentifier == MapSheetPresentationController.compactDetent
        searchViewController.searchDrawer.collectionView.isHidden = isCompact
        searchViewController.searchDrawer.collectionView.isScrollEnabled = !isCompact
        isPresentingPanel = true
        present(panelNavigationController, animated: false) { [weak self] in
            guard let self else { return }
            isPresentingPanel = false
            updatePanelPresentation()
            focusSearchIfNeeded()
        }
    }

    private func updateSheetBottomInset() {
        var inset: CGFloat = 0
        if let tabBar = tabBarController?.tabBar, let window = view.window,
           tabBar.window === window, !tabBar.isHidden {
            let barFrame = tabBar.convert(tabBar.bounds, to: view)
            if barFrame.height > 0, barFrame.maxY >= view.bounds.maxY - view.safeAreaInsets.bottom {
                inset = max(0, view.bounds.maxY - barFrame.minY - window.safeAreaInsets.bottom)
            }
        }
        guard abs(panelNavigationController.additionalSafeAreaInsets.bottom - inset) > 0.5 else { return }
        panelNavigationController.additionalSafeAreaInsets.bottom = inset
        sheetTransitioningDelegate.compactHeightAdjustment = inset
        (panelNavigationController.presentationController as? UISheetPresentationController)?.invalidateDetents()
    }

    private func dismissPresentedPanel() {
        guard !isDismissingPanel else { return }
        if let sheet = panelNavigationController.presentationController as? UISheetPresentationController {
            sheetTransitioningDelegate.selectedDetentIdentifier = sheet.selectedDetentIdentifier ?? .medium
        }
        isDismissingPanel = true
        panelNavigationController.dismiss(animated: false) { [weak self] in
            guard let self else { return }
            isDismissingPanel = false
            finishSuspension()
            updatePanelPresentation()
        }
    }

    private func finishSuspension() {
        let completions = suspensionCompletions
        suspensionCompletions.removeAll()
        completions.forEach { $0() }
    }

    private func attachSidebar() {
        showsSidebar = true
        panelNavigationController.additionalSafeAreaInsets.bottom = 0
        sheetTransitioningDelegate.compactHeightAdjustment = 0
        compactMapNavigationController.setViewControllers([], animated: false)
        sidebarMapNavigationController.setViewControllers([mapViewController], animated: false)
        setViewController(panelNavigationController, for: .primary)
        searchViewController.searchDrawer.collectionView.isScrollEnabled = true
        searchViewController.searchDrawer.collectionView.isHidden = false
        focusSearchIfNeeded()
    }

    private func detachSidebar() {
        showsSidebar = false
        setViewController(nil, for: .primary)
        sidebarMapNavigationController.setViewControllers([], animated: false)
        compactMapNavigationController.setViewControllers([mapViewController], animated: false)
    }

    private func focusSearchIfNeeded() {
        guard pendingSearchFocus, !isPresentingPanel, !isDismissingPanel,
              panelNavigationController.viewIfLoaded?.window != nil else { return }
        if searchViewController.searchDrawer.searchBar.becomeFirstResponder() {
            pendingSearchFocus = false
        }
    }

    private func clearMapSelection() {
        selectedLocation = nil
        for annotation in mapViewController.map.selectedAnnotations {
            mapViewController.map.deselectAnnotation(annotation, animated: false)
        }
    }

    // MARK: - Private Methods

    public func loadData() {
        
        self.locations.removeAll()
        
        Task {
            
            await self.loadEntries()
            self.loadParkingLots()
            self.loadPetrolStations()
            await self.loadCameras()
            
        }
        
    }
    
    // MARK: - Public Methods
    
    public func addLocation(_ location: Location) {
        
        self.locations.append(location)
        
        self.mapViewController.addLocation(location)
        self.searchViewController.addLocation(location)
        
    }

    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}
}

private extension MapContainerViewController {
    func loadEntries() async {
        
        do {
            
            let entries = try await entryManager.get()
            
            self.searchViewController.didReceiveEntries(entries)
            self.mapViewController.didReceiveEntries(entries)
            
            self.locations = self.locations.filter { !($0 is Entry) }
            self.locations.append(contentsOf: entries)
            
        } catch {
            print(error.localizedDescription)
        }
        
    }
    
    func loadParkingLots() {
        
//        parkingLotManager.get { (result) in
//
//            switch result {
//
//            case .success(let parkingLots):
//
//                self.eventBus.notify(ParkingLotDatasource.self) { subscriber in
//                    subscriber.didReceiveParkingLots(parkingLots)
//                }
//
//                self.locations = self.locations.filter { !($0 is ParkingLot) }
//                self.locations.append(contentsOf: parkingLots)
//
//            case .failure(let error):
//                print(error.localizedDescription)
//
//            }
//
//        }
        
    }
    
    func loadCameras() async {

        do {
            let cameras = try await cameraManager.getCameras(shouldReload: false)

            self.searchViewController.didReceiveCameras(cameras)
            self.mapViewController.didReceiveCameras(cameras)

            self.locations = self.locations.filter { !($0 is Camera) }
            self.locations.append(contentsOf: cameras)
        } catch {
            print(error.localizedDescription)
        }

    }
    
    func loadPetrolStations() {
        
        Task {
            do {
                let preferredPetrolType = petrolManager.petrolType
                
                let petrolStations = try await petrolManager.getPetrolStations(
                    coordinate: CLLocationCoordinate2D(latitude: 51.4516, longitude: 6.6255),
                    radius: 10,
                    sorting: .distance,
                    type: preferredPetrolType,
                    shouldReload: false
                )
                
                await MainActor.run {
                    
                    let stations = petrolStations.map { (petrolStation: FuelFeature.PetrolStation) in
                        
                        return MapFeature.PetrolStationViewModel(
                            id: petrolStation.id,
                            name: petrolStation.name,
                            brand: petrolStation.name,
                            street: petrolStation.street,
                            place: petrolStation.place,
                            houseNumber: petrolStation.houseNumber,
                            postCode: petrolStation.postCode,
                            lat: petrolStation.lat, lng: petrolStation.lng,
                            dist: petrolStation.dist,
                            diesel: petrolStation.diesel,
                            e5: petrolStation.e5,
                            e10: petrolStation.e10,
                            price: petrolStation.price,
                            isOpen: petrolStation.isOpen,
                            wholeDay: petrolStation.wholeDay,
                            openingTimes: (petrolStation.openingTimes ?? []).map { openingTime in
                                MapFeature.PetrolStationViewModel.TimeEntry(
                                    text: openingTime.text, start: openingTime.start, end: openingTime.end
                                )
                            },
                            overrides: petrolStation.overrides,
                            state: petrolStation.state
                        )
                        
                    }
                    
                    self.searchViewController.didReceivePetrolStations(stations)
                    self.mapViewController.didReceivePetrolStations(stations)
                    
                    self.locations = self.locations.filter { !($0 is MapFeature.PetrolStationViewModel) }
                    self.locations.append(contentsOf: stations)
                    
                }
            } catch {
                print("Error loading petrol stations: \(error.localizedDescription)")
            }
        }
        
    }
    
}

extension MapContainerViewController: UISheetPresentationControllerDelegate {
    public func sheetPresentationControllerDidChangeSelectedDetentIdentifier(_ sheet: UISheetPresentationController) {
        sheetTransitioningDelegate.selectedDetentIdentifier = sheet.selectedDetentIdentifier ?? .medium
        let isCompact = sheet.selectedDetentIdentifier == MapSheetPresentationController.compactDetent
        searchViewController.searchDrawer.collectionView.isHidden = isCompact
        searchViewController.searchDrawer.collectionView.isScrollEnabled = !isCompact
    }

    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        isPresentingPanel = false
        isDismissingPanel = false
        updatePanelPresentation()
    }
}

extension MapContainerViewController: UINavigationControllerDelegate {
    public func navigationController(
        _ navigationController: UINavigationController,
        willShow viewController: UIViewController,
        animated: Bool
    ) {
        navigationController.setNavigationBarHidden(viewController === searchViewController, animated: animated)
    }

    public func navigationController(
        _ navigationController: UINavigationController,
        didShow viewController: UIViewController,
        animated: Bool
    ) {
        if !(viewController is DetailViewController) { clearMapSelection() }
    }
}

#Preview {
    MapContainerViewController()
}
