//
//  FestivalLiveController.swift
//  moers festival
//
//  Created by Lennart Fischer on 30.05.22.
//  Copyright © 2022 Code for Niederrhein. All rights reserved.
//

import Foundation
import Core
import SwiftUI
import MMPages
import WebKit

public class FestivalLiveController: DefaultHostingController {
    
    private let urlRequest: URLRequest
    private let webViewModel: WebViewStateModel
    
    public override init() {
        
        var components = URLComponents(string: "https://archiv.moers-festival.de/festival22/livestream")!
        
        let queryStandalone = URLQueryItem(name: "standalone", value: "true")
        components.queryItems = [queryStandalone]
        
        guard let url = components.url else { fatalError("Could not create url") }
        
        print(url.absoluteString)
        
        self.urlRequest = URLRequest(url: url)
        self.webViewModel = WebViewStateModel()
        
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = "Live"
        
    }
    
    // MARK: - Setup View -
    
    public override func hostView() -> AnyView {
        
        WebView(
            uRLRequest: urlRequest,
            webViewStateModel: webViewModel,
            onNavigationAction: nil
        )
            .toAnyView()
        
    }
    
}
