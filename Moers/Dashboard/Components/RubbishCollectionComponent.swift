//
//  RubbishCollectionComponent.swift
//  Moers
//
//  Created by Lennart Fischer on 27.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
//import MMAPI
import Combine
import Resolver
import RubbishFeature

class RubbishCollectionComponent: BaseComponent {
    
    @LazyInjected var rubbishService: RubbishService
    
    var rubbishItems: [RubbishPickupItem] = []
    private var cancellables = Set<AnyCancellable>()
    
    lazy var rubbishCardView: DashboardRubbishCardView = {
        
        let cardView = DashboardRubbishCardView()
        
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        return cardView
        
    }()
    
    override init(viewController: UIViewController) {
        super.init(viewController: viewController)
        
        self.register(view: rubbishCardView)
        
        self.rubbishCardView.isUserInteractionEnabled = true
        self.rubbishCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showRubbishCollectionViewController)))
        
        self.load()
        
    }
    
    override func update() {
        
        self.reloadUI()
        
        if rubbishItems.isEmpty && rubbishService.isEnabled {
            self.rubbishCardView.dismissError()
            self.loadRubbishData()
        } else if !rubbishService.isEnabled {
            self.showRubbishCollectionDeactivated()
        }
        
    }
    
    override func refresh() {
        
    }
    
    override func invalidate() {
        
        self.rubbishCardView.stopLoading()
        
    }
    
    @objc public func showRubbishCollectionViewController() {
        
        let rubbishCollectionViewController = generateDetailVC()
        
        viewController?.navigationController?.pushViewController(rubbishCollectionViewController, animated: true)
        
    }
    
    private func generateDetailVC() -> UIViewController {
        return RubbishCollectionViewController()
    }
    
    private func load() {
        
        self.rubbishCardView.startLoading()
        
        let queue = OperationQueue()
        
        queue.addOperation {
            self.loadRubbishData()
        }
        
    }
    
    private func loadRubbishData() {
        
        if rubbishService.isEnabled {
            
            guard let street = rubbishService.rubbishStreet else {
                return
            }
            
            let pickupItems = rubbishService.loadRubbishPickupItems(for: street)
            
            pickupItems.receive(on: DispatchQueue.main)
                .sink { (_: Subscribers.Completion<RubbishLoadingError>) in
                    
                } receiveValue: { (items: [RubbishPickupItem]) in
                    
                    self.rubbishItems = items
                    
                    OperationQueue.main.addOperation {
                        
                        self.rubbishCardView.stopLoading()
                        self.rubbishCardView.dismissError()
                        
                        self.reloadUI()
                        
                    }
                    
                }
                .store(in: &cancellables)
            
        } else {
            
            OperationQueue.main.addOperation {
                
                self.showRubbishCollectionDeactivated()
                
            }
            
        }
        
    }
    
    private func reloadUI() {
        
        if rubbishItems.count >= 3 {
            self.rubbishCardView.itemView1.rubbishCollectionItem = rubbishItems[0]
            self.rubbishCardView.itemView2.rubbishCollectionItem = rubbishItems[1]
            self.rubbishCardView.itemView3.rubbishCollectionItem = rubbishItems[2]
        } else if rubbishItems.count >= 2 {
            self.rubbishCardView.itemView1.rubbishCollectionItem = rubbishItems[0]
            self.rubbishCardView.itemView2.rubbishCollectionItem = rubbishItems[1]
        } else if rubbishItems.count >= 1 {
            self.rubbishCardView.itemView1.rubbishCollectionItem = rubbishItems[0]
        } else if rubbishItems.isEmpty {
            self.rubbishCardView.stopLoading()
            self.rubbishCardView.showError(
                withTitle: "Warnung",
                message: "Leider können momentan keine weiteren Abholtermine angezeigt werden, da die Daten für dieses Jahr noch nicht zur Verfügung stehen. Wir arbeiten daran, so schnell wie möglich aktuelle Termine bereitstellen zu können!"
            )
        }
        
    }
    
    private func showRubbishCollectionDeactivated() {
        
        self.rubbishCardView.stopLoading()
        self.rubbishCardView.showError(withTitle: String.localized("WasteErrorTitle"), message: String.localized("WasteErrorMessage"))
        
    }
    
}
