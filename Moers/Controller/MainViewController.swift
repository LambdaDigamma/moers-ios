//
//  MainViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 15.04.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import ESTabBarController

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        guard let controller = tabBarController as? ESTabBarController else { return }
        
        controller.shouldHijackHandler = { tabBarController, viewController, index in
            index == 1 ? true : false
        }
        
        controller.viewControllers?[1].tabBarItem = ESTabBarItem(MapItemContentView(), title: nil, image: #imageLiteral(resourceName: "search"), selectedImage: #imageLiteral(resourceName: "search"))
        
        controller.didHijackHandler = {
            [weak tabBarController] tc, vc, index in
            
            print("Search!")
            
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        guard let controller = tabBarController as? ESTabBarController else { return }
        
        controller.shouldHijackHandler = { (_, _, _) in false }
        
        controller.viewControllers?[1].tabBarItem = ESTabBarItem(MapItemContentView(), title: nil, image: #imageLiteral(resourceName: "map_marker"), selectedImage: #imageLiteral(resourceName: "map_marker"))
        
    }
    
}
