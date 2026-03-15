//
//  MainMapViewController.swift
//  CityOS
//
//  Created by Lennart Fischer on 31.01.26.
//

import Core
import UIKit

public class MainMapViewController: UIViewController {
    
    lazy var mapView = { CoreViewFactory.map() }()
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.tabBarController?.tabBar.isHidden = true
        
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
//        let viewController = UIViewController()
//        let nav = UINavigationController(rootViewController: viewController)
//        nav.modalPresentationStyle = .pageSheet
//        
//        if let sheetController = self.sheetPresentationController {
//            sheetController.detents = [
//                UISheetPresentationController.Detent.custom(resolver: { context in
//                    context.maximumDetentValue * 0.3
//                }),
//                UISheetPresentationController.Detent.medium(),
//                UISheetPresentationController.Detent.large()
//            ]
//            sheetController.prefersGrabberVisible = true
//            sheetController.prefersScrollingExpandsWhenScrolledToEdge = false
//        }
//        
//        self.present(nav, animated: false)
        
        let vc = SheetContentViewController()
//        let nav = UINavigationController(rootViewController: vc)
        vc.modalPresentationStyle = .pageSheet
        if let sheet = vc.sheetPresentationController {
            if #available(iOS 16.0, *) {
                sheet.detents = [
                    UISheetPresentationController.Detent.large(),
                    UISheetPresentationController.Detent.medium(),
                    UISheetPresentationController.Detent.custom { [weak self] info in
                        
                        return vc.tabBarHeight
                        
//                        if let viewController = viewController as? SheetContentViewController {
//                            return viewController.tabBarHeight
//                        }
                        
                    }
                ]
                sheet.largestUndimmedDetentIdentifier = .medium
                sheet.prefersGrabberVisible = true
            } else {
                sheet.detents = [.medium(), .large()]
            }
        }
        self.present(vc, animated: true)
        
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        
    }
    
    
    
    private func setupUI() {
        
        self.view.addSubview(mapView)
        
        let constraints = [
            mapView.topAnchor.constraint(equalTo: self.view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
}
