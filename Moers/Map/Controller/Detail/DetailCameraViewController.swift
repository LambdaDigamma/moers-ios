//
//  DetailCameraViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 21.07.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import Crashlytics
import MMAPI
import MMUI

class DetailCameraViewController: UIViewController {

    lazy var topSeperator: UIView = { ViewFactory.blankView() }()
    lazy var showButton: UIButton = { ViewFactory.button() }()
    
    var selectedCamera: Camera? { didSet { setupCamera(selectedCamera) } }
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        self.setupConstraints()
        self.setupTheming()
        
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        
        self.view.addSubview(showButton)
        
        self.topSeperator.alpha = 0.5
        
        self.showButton.setTitle("Anschauen", for: .normal)
        self.showButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: UIFont.Weight.semibold)
        self.showButton.addTarget(self, action: #selector(showCamera), for: .touchUpInside)
        self.showButton.layer.cornerRadius = 8
        self.showButton.clipsToBounds = true
        
    }
    
    private func setupTheming() {
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { (themeable, theme) in
            
            themeable.view.backgroundColor = theme.backgroundColor
            themeable.topSeperator.backgroundColor = theme.decentColor
            themeable.showButton.setBackgroundColor(color: #colorLiteral(red: 0.276827544, green: 0.6099686027, blue: 0.3140196502, alpha: 1), forState: .normal)
            themeable.showButton.setBackgroundColor(color: #colorLiteral(red: 0.276827544, green: 0.6099686027, blue: 0.3140196502, alpha: 1).darker(by: 10)!, forState: .selected)
            themeable.showButton.setTitleColor(UIColor.white, for: .normal)
            
        }
        
    }
    
    private func setupConstraints() {
        
        let constraints = [showButton.topAnchor.constraint(equalTo: self.view.topAnchor, constant: 8),
                           showButton.leftAnchor.constraint(equalTo: self.view.leftAnchor),
                           showButton.rightAnchor.constraint(equalTo: self.view.rightAnchor),
                           showButton.heightAnchor.constraint(equalToConstant: 50),
                           showButton.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -8)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    @objc private func showCamera() {
        
        let viewController = CameraViewController()
        
        guard let camera = selectedCamera else { return }
        
        AnalyticsManager.shared.logPano(camera.id)
        
        viewController.panoID = camera.id
        
        navigationController?.pushViewController(viewController, animated: true)
        
    }
    
    private func setupCamera(_ camera: Camera?) {
        
        guard let camera = camera else { return }
        
        Answers.logCustomEvent(withName: "Detail - Camera", customAttributes: ["name": camera.name, "panoID": camera.id])
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "viewCamera" {
            
            if let destination = segue.destination as? CameraViewController {
                
                guard let cam = selectedCamera else { return }
                
                destination.panoID = cam.id
                
            }
            
        }
        
    }
    
}
