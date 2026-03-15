//
//  CountdownViewController.swift
//  moers festival
//
//  Created by Lennart Fischer on 13.05.20.
//  Copyright © 2020 CodeForNiederrhein. All rights reserved.
//

import UIKit
import Core

class CountdownViewController: UIViewController {
    
    private lazy var scrollView: UIScrollView = { ViewFactory.scrollView() }()
    private lazy var contentView: UIStackView = { ViewFactory.stackView() }()
    private lazy var countdownLabel: UILabel = { ViewFactory.label() }()
    private lazy var headerImageView: UIImageView = { ViewFactory.imageView() }()
    private lazy var descriptionLabel: UILabel = { ViewFactory.label() }()
    
    private let horizontalSpacing: CGFloat = UIDevice.current.userInterfaceIdiom == .phone ? 16 : 0
    
    private var timer: Timer!
    private let calendar = Calendar.current
    
    private let startDate: Date
    
    init(startDate: Date) {
        self.startDate = startDate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.setupConstraints()
        self.setupTheming()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.updateTimeLabel()
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self,
                                          selector: #selector(updateTimeLabel),
                                          userInfo: nil, repeats: true)
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.timer?.invalidate()
        
    }
    
    // MARK: - UI
    
    private func setupUI() {
        
        self.view.addSubview(scrollView)
        self.scrollView.addSubview(contentView)
        self.contentView.addArrangedSubview(headerImageView)
        self.contentView.addArrangedSubview(
            ContainerView(
                contentView: countdownLabel,
                edgeInsets: UIEdgeInsets(
                    top: 0,
                    left: horizontalSpacing,
                    bottom: 0,
                    right: horizontalSpacing
                )
            )
        )
        self.contentView.addArrangedSubview(
            ContainerView(
                contentView: descriptionLabel,
                edgeInsets: UIEdgeInsets(
                    top: 0,
                    left: horizontalSpacing,
                    bottom: 0,
                    right: horizontalSpacing
                )
            )
        )
        self.scrollView.showsVerticalScrollIndicator = false
        self.contentView.axis = .vertical
        self.countdownLabel.font = .monospacedDigitSystemFont(ofSize: 40, weight: .semibold)
        self.countdownLabel.textAlignment = .center
        self.countdownLabel.adjustsFontSizeToFitWidth = true
        self.countdownLabel.minimumScaleFactor = 0.25
        self.headerImageView.image = UIImage(named: "plakat")
        self.headerImageView.contentMode = .scaleAspectFill
        self.headerImageView.layer.masksToBounds = true
        self.descriptionLabel.font = .systemFont(ofSize: 16, weight: .regular)
        self.descriptionLabel.text = String.localized("CountdownText")
        self.descriptionLabel.numberOfLines = 0
        
    }
    
    private func setupConstraints() {
        
        let margins = self.view.readableContentGuide
        
        let constraints = [
            scrollView.topAnchor.constraint(equalTo: margins.topAnchor, constant: 0),
            scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: margins.leadingAnchor, constant: -20),
            contentView.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: 20),
            contentView.topAnchor.constraint(equalTo: self.scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor, constant: -60),
            headerImageView.heightAnchor.constraint(equalTo: headerImageView.widthAnchor, multiplier: 7/10),
        ]
        
        NSLayoutConstraint.activate(constraints)
        
        self.contentView.setCustomSpacing(4, after: headerImageView)
        self.contentView.setCustomSpacing(12, after: countdownLabel)
        
    }
    
    private func setupTheming() {
        
        self.view.backgroundColor = UIColor.systemBackground
        self.countdownLabel.textColor = UIColor.label
        self.descriptionLabel.textColor = UIColor.label
        
    }
    
    // MARK: - Time Handling
    
    @objc private func updateTimeLabel() {
        
        let timeLeft = calendar.dateComponents([.day, .hour, .minute, .second], from: Date(), to: startDate)

        guard let days = timeLeft.day, let hours = timeLeft.hour, let minutes = timeLeft.minute, let seconds = timeLeft.second else { return }
        
        countdownLabel.text = "\(days) \(String.localized("CountdownDays")) \(hours) \(String.localized("CountdownHours")) \(minutes) \(String.localized("CountdownMinutes")) \(seconds) \(String.localized("CountdownSeconds"))"
        
    }
    
}
