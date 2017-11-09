//
//  CamerViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 25.09.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import UIKit
import WebKit

class CameraViewController: UIViewController {

    var panoID: PanoID? = nil
    
    @IBOutlet weak var webView: WKWebView!
    
    @IBAction func back(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: nil)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        guard let panoID = panoID else { return }
        
        guard let url = URL(string: "http://360moers.de/tour.html?s=pano\(panoID)&skipintro&html5=only") else { return }
        
        let request = URLRequest(url: url)
        
        webView.load(request)
        
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .allButUpsideDown
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}
