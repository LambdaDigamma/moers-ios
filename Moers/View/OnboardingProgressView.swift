//
//  OnboardingProgressView.swift
//  Moers
//
//  Created by Lennart Fischer on 14.10.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit

class OnboardingProgressView: UIView {

    private lazy var currentStepLabel: UILabel = { return ViewFactory.label() }()
    private lazy var progressView: UIProgressView = { return ViewFactory.progressView() }()
    private lazy var separatorView: UIView = { return ViewFactory.blankView() }()
    
    public var accentColor: UIColor! {
        didSet {
            progressView.progressTintColor = accentColor
        }
    }
    
    public var decentColor: UIColor! {
        didSet {
            progressView.trackTintColor = decentColor
            separatorView.backgroundColor = decentColor
        }
    }
    
    public var textColor: UIColor! {
        didSet {
            currentStepLabel.textColor = textColor
        }
    }
    
    public var progress: Float = 0 {
        didSet {
            self.progressView.setProgress(progress, animated: true)
        }
    }
    
    public var currentStep: String = "" {
        didSet {
            self.currentStepLabel.text = currentStep
        }
    }
    
    init() {
        super.init(frame: CGRect.zero)
        
        self.addSubview(currentStepLabel)
        self.addSubview(progressView)
        self.addSubview(separatorView)
        
        self.currentStepLabel.textAlignment = .center
        self.currentStepLabel.font = UIFont.boldSystemFont(ofSize: 17)
        self.separatorView.alpha = 0.75
        
        self.setupConstraints()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupConstraints() {
        
        let constraints = [currentStepLabel.topAnchor.constraint(equalTo: self.topAnchor),
                           currentStepLabel.leftAnchor.constraint(equalTo: self.leftAnchor),
                           currentStepLabel.rightAnchor.constraint(equalTo: self.rightAnchor),
                           progressView.topAnchor.constraint(equalTo: self.currentStepLabel.bottomAnchor, constant: 16),
                           progressView.leftAnchor.constraint(equalTo: self.leftAnchor),
                           progressView.rightAnchor.constraint(equalTo: self.rightAnchor),
                           progressView.heightAnchor.constraint(equalToConstant: 3),
                           separatorView.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 20),
                           separatorView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
                           separatorView.heightAnchor.constraint(equalToConstant: 1),
                           separatorView.widthAnchor.constraint(equalToConstant: 48),
                           separatorView.bottomAnchor.constraint(equalTo: self.bottomAnchor)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
}
