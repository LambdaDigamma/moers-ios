//
//  DetailCameraViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 25.09.17.
//  Copyright © 2017 Lennart Fischer. All rights reserved.
//

import UIKit

class DetailCameraViewController: UIViewController {
    
    var selectedCamera: Camera? {
        
        didSet {}
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
