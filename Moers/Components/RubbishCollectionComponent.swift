//
//  RubbishCollectionComponent.swift
//  Moers
//
//  Created by Lennart Fischer on 27.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit

class RubbishCollectionComponent: BaseComponent {
    
    let rubbishItems: [RubbishCollectionItem] = []
    
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
        
        if rubbishItems.count == 0 && RubbishManager.shared.isEnabled {
            self.rubbishCardView.dismissError()
            self.loadRubbishData()
        } else if !RubbishManager.shared.isEnabled {
            self.showRubbishCollectionDeactivated()
        }
        
    }
    
    override func invalidate() {
        
        self.rubbishCardView.stopLoading()
        
    }
    
    @objc public func showRubbishCollectionViewController() {
        
        let rubbishCollectionViewController = RubbishCollectionViewController()
        
        viewController?.navigationController?.pushViewController(rubbishCollectionViewController, animated: true)
        
    }
    
    private func load() {
        
        self.rubbishCardView.startLoading()
        
        let queue = OperationQueue()
        
        queue.addOperation {
            self.loadRubbishData()
        }
        
    }
    
    private func loadRubbishData() {
        
        if RubbishManager.shared.isEnabled {
            
            RubbishManager.shared.loadItems(completion: { (items) in
                
                OperationQueue.main.addOperation {
                    
                    self.rubbishCardView.stopLoading()
                    
                    if items.count >= 3 {
                        self.rubbishCardView.itemView1.rubbishCollectionItem = items[0]
                        self.rubbishCardView.itemView2.rubbishCollectionItem = items[1]
                        self.rubbishCardView.itemView3.rubbishCollectionItem = items[2]
                    } else if items.count >= 2 {
                        self.rubbishCardView.itemView1.rubbishCollectionItem = items[0]
                        self.rubbishCardView.itemView2.rubbishCollectionItem = items[1]
                    } else if items.count >= 1 {
                        self.rubbishCardView.itemView1.rubbishCollectionItem = items[0]
                    }
                    
                }
                
            })
            
        } else {
            
            OperationQueue.main.addOperation {
                
                self.showRubbishCollectionDeactivated()
                
            }
            
        }
        
    }
    
    private func showRubbishCollectionDeactivated() {
        
        self.rubbishCardView.stopLoading()
        self.rubbishCardView.showError(withTitle: "Abfallkalender deaktiviert", message: "Du kannst den Abfallkalender in den Einstellungen aktivieren.")
        
    }
    
}
