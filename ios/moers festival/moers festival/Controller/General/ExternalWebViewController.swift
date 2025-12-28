//
//  ExternalWebViewController.swift
//  moers festival
//
//  Created by Lennart Fischer on 11.04.21.
//  Copyright © 2021 Code for Niederrhein. All rights reserved.
//

import UIKit
import WebKit

class ExternalWebViewController: UIViewController {
    
    lazy var webkitView: WKWebView = {
        let view = WKWebView(frame: .zero, configuration: configuration())
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private var url: URL
    
    public var navigationCallback: ((URL) -> ())?
    
    init(url: URL) {
        self.url = url
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.setupConstraints()
        
    }
    
    private func setupUI() {
        
        self.view.addSubview(webkitView)
        self.view.backgroundColor = .black
        self.webkitView.backgroundColor = .black
        self.webkitView.isOpaque = false
        
        var request = URLRequest(url: url)
        request.addValue("de,en-US;q=0.7,en;q=0.3", forHTTPHeaderField: "Accept-Language")
        
        self.webkitView.load(request)
        
    }
    
    private func setupConstraints() {
        
        let constraints = [
            webkitView.topAnchor.constraint(equalTo: self.view.topAnchor),
            webkitView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            webkitView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            webkitView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
        ]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func configuration() -> WKWebViewConfiguration {
        
        let configuration = WKWebViewConfiguration()
        
        return configuration
        
    }
    
}
