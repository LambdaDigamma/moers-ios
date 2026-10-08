//
//  InactiveViewController.swift
//  moers festival tvOS
//
//  Created by Lennart Fischer on 27.05.20.
//  Copyright © 2020 CodeForNiederrhein. All rights reserved.
//

import UIKit
import Events

class InactiveStreamViewController: UIViewController {
    
    public var reloadAction: (() -> Void)?
    public var livestreamData: Events.LivestreamData? {
        didSet {
            if let livestreamData = livestreamData {
                self.setupContinuePlaybackTimer(livestreamData: livestreamData)
            }
        }
    }
    
    private var continuePlaybackTimer: Timer!
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var reloadButton: UIButton!
    @IBOutlet weak var errorImageView: UIImageView!
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleLabel.text = String(localized: "The livestream is not active.")
        descriptionLabel.text = String(localized: "The livestream will reload automatically when it resumes. If it does not, you can reload it manually.")
        reloadButton.setTitle(String(localized: "Reload"), for: .normal)
        
        
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        UIView.animate(withDuration: 0.75, delay: 0, options: .curveLinear, animations: {
            self.errorImageView.alpha = 1
        }, completion: nil)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.continuePlaybackTimer?.invalidate()
        
    }
    
    // MARK: - UI
    
    private func setupUI() {
        
    }
    
    @IBAction func reloadButtonPressed(_ sender: UIButton) {
        
        self.dismiss(animated: true, completion: self.reloadAction)
        
    }
    
    // MARK: - Timer Handling
    
    private func setupContinuePlaybackTimer(livestreamData: Events.LivestreamData) {
        
        if let nextStartDate = livestreamData.events
            .map({ $0.model })
            .filter({ $0.startDate != nil })
            .filter({ $0.startDate ?? Date(timeIntervalSinceNow: -3600) > Date() })
            .chronologically()
            .first?
            .startDate {
        
            self.continuePlaybackTimer = Timer(fireAt: nextStartDate, interval: 0,
                                               target: self, selector: #selector(fireContinuePlayback),
                                               userInfo: nil, repeats: false)
            
            RunLoop.main.add(self.continuePlaybackTimer, forMode: .common)
            
        }
    }
    
    @objc private func fireContinuePlayback() {
        
        self.dismiss(animated: true, completion: reloadAction)
        
    }

    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}
}
