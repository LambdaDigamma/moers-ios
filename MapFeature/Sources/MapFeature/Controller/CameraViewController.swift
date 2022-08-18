//
//  CameraViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 21.07.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import WebKit
import Core

class CameraViewController: UIViewController {

    lazy var webView: WKWebView = { CoreViewFactory.webView() }()

    var panoID: PanoID?
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        self.setupConstraints()
        
        guard let panoID = panoID else { return }
        
        guard let url = URL(string: "http://360moers.de/tour.html?s=pano\(panoID)&skipintro&html5=only)") else { return }
        
        let request = URLRequest(url: url)
        
        webView.load(request)
        
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        
        self.view.addSubview(webView)
        
        self.navigationItem.largeTitleDisplayMode = .never
        
    }
    
    private func setupConstraints() {
        
        let constraints = [webView.topAnchor.constraint(equalTo: self.safeTopAnchor),
                           webView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
                           webView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
                           webView.bottomAnchor.constraint(equalTo: self.safeBottomAnchor)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .allButUpsideDown
    }
    
}
