//
//  SoundCloudTrackView.swift
//  
//
//  Created by Lennart Fischer on 06.02.20.
//

#if canImport(WebKit)

import UIKit
import WebKit

class SoundCloudTrackView: WKWebView {
    
    init() {
        
        let config = WKWebViewConfiguration()
        
        config.allowsInlineMediaPlayback = true
        config.ignoresViewportScaleLimits = true
        
        super.init(frame: .zero, configuration: config)
        
        self.setupConstraints()
        self.setupWebview()
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        
        
    }
    
    private func setupConstraints() {
        
        let constraints = [
            self.heightAnchor.constraint(equalToConstant: 166)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupWebview() {
        
        let html = """
        <html>
        <body>
        <iframe width="100%" height="100%" scrolling="no" frameborder="no" src="https://w.soundcloud.com/player/?url=https%3A//api.soundcloud.com/tracks/34019569&amp;color=0066cc"></iframe>
        </body>
        </html>
        """
        
        self.loadHTMLString(html, baseURL: nil)
        
    }
    
    
}

#endif
