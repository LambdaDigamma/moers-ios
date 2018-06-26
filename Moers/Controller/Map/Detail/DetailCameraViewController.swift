//
//  DetailCameraViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 25.09.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import UIKit
import Crashlytics

class DetailCameraViewController: UIViewController {
    
    var selectedCamera: Camera? {
        
        didSet {
            
            guard let camera = selectedCamera else { return }
            
            Answers.logCustomEvent(withName: "Detail - Camera", customAttributes: ["name": camera.name, "panoID": camera.panoID])
            
        }
        
    }
    
    @IBAction func viewCamera(_ sender: UIButton) {
        
        resetNavBar()
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let vc = storyboard.instantiateViewController(withIdentifier: "CameraViewController") as! CameraViewController
        
        guard let cam = selectedCamera else { return }
        
        vc.panoID = cam.panoID
        
        navigationController?.pushViewController(vc, animated: true)
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    fileprivate func resetNavBar() {
        
        navigationController?.navigationBar.barTintColor = UIColor(red: 0.85, green: 0.12, blue: 0.09, alpha: 1.0)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white]
        
        if let statusBar = UIApplication.shared.value(forKey: "statusBar") as? UIView {
            statusBar.alpha = 1
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "viewCamera" {
            
            if let destination = segue.destination as? CameraViewController {
                
                guard let cam = selectedCamera else { return }
                
                destination.panoID = cam.panoID
                
            }
            
        }
        
    }
    
}
