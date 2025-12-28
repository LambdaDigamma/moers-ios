//
//  CountdownViewController.swift
//  moers festival tvOS
//
//  Created by Lennart Fischer on 27.05.20.
//  Copyright © 2020 CodeForNiederrhein. All rights reserved.
//

import UIKit
import TVUIKit
import MMEvents

class CountdownViewController: UIViewController {
    
    public var livestreamData: MMEvents.LivestreamData? {
        didSet {
            self.setupCountdownTimer()
        }
    }
    public var fireCompletion: (() -> Void)?
    
    public var startDate: Date? {
        return livestreamData?.streamConfig.startDate
    }
    
    private var countdownFireTimer: Timer!
    private var labelUpdateTimer: Timer!
    private let calendar = Calendar.current
    
    // MARK: - UI
    
    @IBOutlet weak var marketingImageView: UIImageView!
    @IBOutlet weak var countdownLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateTimeLabel()
        self.labelUpdateTimer = Timer.scheduledTimer(
            timeInterval: 1, target: self,
            selector: #selector(updateTimeLabel),
            userInfo: nil, repeats: true
        )
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.labelUpdateTimer?.invalidate()
        self.countdownFireTimer?.invalidate()
        
    }
    
    private func setupUI() {
        
        self.marketingImageView.layer.cornerRadius = 20
        self.marketingImageView.clipsToBounds = true
        
    }
    
    private func setupCountdownTimer() {
        
        if let startDate = startDate {
            
            self.countdownFireTimer = Timer(fireAt: startDate, interval: 0,
                                            target: self, selector: #selector(fireCountdown),
                                            userInfo: nil, repeats: false)
            
            RunLoop.main.add(self.countdownFireTimer, forMode: .common)
            
        }
        
    }
    
    // MARK: - Time Handling
    
    @objc private func updateTimeLabel() {
        
        if let startDate = startDate {
            
            let timeLeft = calendar.dateComponents([.day, .hour, .minute, .second], from: Date(), to: startDate)

            guard let days = timeLeft.day, let hours = timeLeft.hour, let minutes = timeLeft.minute, let seconds = timeLeft.second else { return }
            
            countdownLabel.text = "\(days) \(String.localized("CountdownDays")) \(hours) \(String.localized("CountdownHours")) \(minutes) \(String.localized("CountdownMinutes")) \(seconds) \(String.localized("CountdownSeconds"))"
            
        } else {
            countdownLabel.text = "Start unbekannt"
        }
        
    }
    
    @objc private func fireCountdown() {
        
        self.dismiss(animated: true, completion: fireCompletion)
        
    }
    
}
