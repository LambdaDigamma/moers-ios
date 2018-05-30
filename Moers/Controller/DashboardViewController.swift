//
//  DashboardViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 20.04.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import UserNotifications
import CoreLocation
import MapKit
import Reachability

class DashboardViewController: UIViewController {

    // MARK: - UI
    
    lazy var scrollView: UIScrollView = {
        
        let scrollView = UIScrollView()
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        
        return scrollView
        
    }()
    
    lazy var cardStackView: UIStackView = {
        
        let stackView = UIStackView()
        
        stackView.axis = .vertical
        stackView.distribution = .fill
        stackView.alignment = .fill
        stackView.spacing = 16
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
        
    }()
    
    var components: [BaseComponent] = []
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.addSubview(scrollView)
        self.scrollView.addSubview(cardStackView)
        
        let rubbishComponent = RubbishCollectionComponent(viewController: self)
        let petrolComponent = AveragePetrolPriceComponent(viewController: self)
        
        self.registerComponents(components: [petrolComponent, rubbishComponent])
        
        self.setupConstraints()
        self.setupTheming()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.triggerUpdate()
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        components.forEach { $0.invalidate() }
        
    }
    
    // MARK: - Private Methods
    
    private func setupConstraints() {
        
        let constraints = [scrollView.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 0),
                           scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
                           scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
                           scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: 0),
                           cardStackView.leftAnchor.constraint(equalTo: self.scrollView.leftAnchor, constant: 16),
                           cardStackView.rightAnchor.constraint(equalTo: self.scrollView.rightAnchor, constant: -16),
                           cardStackView.topAnchor.constraint(equalTo: self.scrollView.topAnchor, constant: 16),
                           cardStackView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor, constant: -16),
                           cardStackView.widthAnchor.constraint(equalTo: self.view.widthAnchor, constant: -32)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { themeable, theme in
            
            themeable.view.backgroundColor = theme.backgroundColor
            
        }
        
    }

    private func setupReachability() {
        
        guard let reachability = Reachability() else { return }
        
        reachability.whenReachable = { reachability in
            
            if reachability.connection == .cellular {
                
            } else if reachability.connection == .wifi {
                
            }
            
        }
        
        reachability.whenUnreachable = { _ in
            
            
            
        }
        
        
        
    }
    
    private func registerComponents(components: [BaseComponent]) {
        
        self.components = components
        
        components.forEach {
            $0.view.translatesAutoresizingMaskIntoConstraints = false
            cardStackView.addArrangedSubview($0.view)
        }
        
    }
    
    public func triggerUpdate() {
        
        components.forEach { $0.update() }
        
    }
    
}
