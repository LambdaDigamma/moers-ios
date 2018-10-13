//
//  DetailRestaurantViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 05.10.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import SafariServices

class DetailRestaurantViewController: UIViewController {

    public var selectedRestaurant: Restaurant? { didSet {  } }
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        self.setupTheming()
        
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        
        
        
    }
    
    private func setupTheming() {
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { (themeable, theme) in
            
            
            
        }
        
    }
    
    
    
    @objc private func call() {
        
        guard let restaurant = selectedRestaurant else { return }
        guard let phone = restaurant.phone?.replacingOccurrences(of: " ", with: "") else { return }
        guard let url = URL(string: "telprompt://" + phone) else { return }
        
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.open(url, options: convertToUIApplicationOpenExternalURLOptionsKeyDictionary([:]), completionHandler: nil)
        }
        
    }
    
    @objc private func openWebsite() {
        
        guard let restaurant = selectedRestaurant else { return }
        guard var urlString = restaurant.url else { return }
        
        if !urlString.starts(with: "https://") && !urlString.starts(with: "http://") {
            urlString = "http://" + urlString
        }
        
        guard let url = URL(string: urlString) else { return }
        
        let svc = SFSafariViewController(url: url)
        svc.preferredBarTintColor = navigationController?.navigationBar.barTintColor
        svc.preferredControlTintColor = navigationController?.navigationBar.tintColor
        self.present(svc, animated: true, completion: nil)
        
    }
    
//    static func fromStoryboard() -> DetailShopViewController {

        // TODO: Instantiate from Storyboard
        
//        let storyboard = UIStoryboard(name: "DetailViewControllers", bundle: nil)
//
//        return storyboard.instantiateViewController(withIdentifier: "DetailShopViewController") as! DetailShopViewController
        
//    }
    
}
