//
//  RubbishCollectionComponent.swift
//  Moers
//
//  Created by Lennart Fischer on 27.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import MMAPI

class RubbishCollectionComponent: BaseComponent, UIViewControllerPreviewingDelegate {
    
    var rubbishItems: [RubbishCollectionItem] = []
    
    lazy var rubbishCardView: DashboardRubbishCardView = {
        
        let cardView = DashboardRubbishCardView()
        
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        return cardView
        
    }()
    
    override init(viewController: UIViewController) {
        super.init(viewController: viewController)
        
        self.register(view: rubbishCardView)
        
        self.viewController?.registerForPreviewing(with: self, sourceView: rubbishCardView)
        
        self.rubbishCardView.isUserInteractionEnabled = true
        self.rubbishCardView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showRubbishCollectionViewController)))
        
        self.load()
        
    }
    
    override func update() {
        
        self.reloadUI()
        
        if rubbishItems.count == 0 && RubbishManager.shared.isEnabled {
            self.rubbishCardView.dismissError()
            self.loadRubbishData()
        } else if !RubbishManager.shared.isEnabled {
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
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        
        let queue = OperationQueue()
        
        queue.addOperation {
            self.loadRubbishData()
        }
        
    }
    
    private func loadRubbishData() {
        
        if RubbishManager.shared.isEnabled {
            
            RubbishManager.shared.loadItems(completion: { (items) in
                
                self.rubbishItems = items
                
                OperationQueue.main.addOperation {
                    
                    UIApplication.shared.isNetworkActivityIndicatorVisible = false
                    
                    self.rubbishCardView.stopLoading()
                    
                    self.reloadUI()
                    
                }
                
            })
            
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
        } else if rubbishItems.count == 0 {
            self.rubbishCardView.stopLoading()
            self.rubbishCardView.showError(withTitle: "Warnung", message: "Leider können momentan keine weiteren Abholtermine angezeigt werden, da die Daten für dieses Jahr noch nicht zur Verfügung stehen. Wir arbeiten daran, so schnell wie möglich aktuelle Termine bereitstellen zu können!")
        }
        
    }
    
    private func showRubbishCollectionDeactivated() {
        
        self.rubbishCardView.stopLoading()
        self.rubbishCardView.showError(withTitle: String.localized("WasteErrorTitle"), message: String.localized("WasteErrorMessage"))
        
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
        
        previewingContext.sourceRect = rubbishCardView.frame
        
        return generateDetailVC()
        
    }
    
    func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
        
        showRubbishCollectionViewController()
        
    }
    
}