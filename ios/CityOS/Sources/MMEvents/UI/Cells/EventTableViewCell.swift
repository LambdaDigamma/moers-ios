//
//  EventTableViewCell.swift
//  MMUI
//
//  Created by Lennart Fischer on 12.06.19.
//  Copyright © 2019 LambdaDigamma. All rights reserved.
//

#if canImport(UIKit)

import UIKit

public class EventTableViewCell: UITableViewCell {
    
    public static var identifier = "eventTableViewCell"
    
    lazy var indicatorView = { ViewFactory.blankView() }()
    lazy var titleLabel = { ViewFactory.label() }()
    lazy var subtitleLabel = { ViewFactory.label() }()
    lazy var heartImageView = { ViewFactory.imageView() }()
    
    public var event: EventViewModel<Event>? {
        didSet {
            
            guard let event = event else { return }
            
            self.titleLabel.text = event.model.name
            self.subtitleLabel.text = event.subtitle
            
            if event.isLiked {
                self.heartImageView.image = Images.heartFill.withRenderingMode(.alwaysTemplate)
            }
            
            if let color = event.model.extras?.color {
                
                if color == "yellow" {
                    self.indicatorView.backgroundColor = EventColors.yellow
                } else if color == "green" {
                    self.indicatorView.backgroundColor = EventColors.green
                } else if color == "magenta" {
                    self.indicatorView.backgroundColor = EventColors.magenta
                } else if color == "blue" {
                    self.indicatorView.backgroundColor = EventColors.lightBlue
                } else {
                    self.indicatorView.backgroundColor = UIColor.gray
                }
                
            }
            
        }
    }
    
    // MARK: - Inits
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.selectionStyle = .none
        
        self.setupUI()
        self.setupConstraints()
        self.setupTheming()
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func prepareForReuse() {
        super.prepareForReuse()
        
        self.heartImageView.image = nil
        
    }
     
    // MARK: - Private Methods
    
    private func setupConstraints() {
        
        let margins = contentView.layoutMarginsGuide
        
        let constraints: [NSLayoutConstraint] = [
            indicatorView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            indicatorView.topAnchor.constraint(equalTo: margins.topAnchor),
            indicatorView.bottomAnchor.constraint(equalTo: margins.bottomAnchor),
            indicatorView.widthAnchor.constraint(equalToConstant: 2),
            titleLabel.leadingAnchor.constraint(equalTo: indicatorView.trailingAnchor, constant: 8),
            titleLabel.topAnchor.constraint(equalTo: margins.topAnchor, constant: 0),
            titleLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: 0),
            titleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 20),
            subtitleLabel.leadingAnchor.constraint(equalTo: indicatorView.trailingAnchor, constant: 8),
            subtitleLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            subtitleLabel.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: -8),
            subtitleLabel.heightAnchor.constraint(greaterThanOrEqualToConstant: 18),
            subtitleLabel.bottomAnchor.constraint(equalTo: margins.bottomAnchor, constant: 0),
            heartImageView.centerYAnchor.constraint(equalTo: margins.centerYAnchor),
            heartImageView.trailingAnchor.constraint(equalTo: margins.trailingAnchor, constant: 0),
            heartImageView.widthAnchor.constraint(equalToConstant: 10),
            heartImageView.heightAnchor.constraint(equalToConstant: 10)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupUI() {
        
        self.contentView.layoutMargins = UIEdgeInsets(top: 8.0, left: 0, bottom: 8.0, right: 0)
        
        self.contentView.addSubview(indicatorView)
        self.contentView.addSubview(titleLabel)
        self.contentView.addSubview(subtitleLabel)
        self.contentView.addSubview(heartImageView)
        
        self.titleLabel.font = UIFont.boldSystemFont(ofSize: 18)
        self.titleLabel.lineBreakMode = .byWordWrapping
        self.titleLabel.numberOfLines = 0
        self.subtitleLabel.font = UIFont.systemFont(ofSize: 16)
        self.subtitleLabel.lineBreakMode = .byWordWrapping
        self.subtitleLabel.numberOfLines = 0
        
    }
    
    private func setupTheming() {
        
#if !os(tvOS)
        self.backgroundColor = UIColor.systemBackground
#endif
        self.indicatorView.backgroundColor = EventPackageConfiguration.accentColor
        self.titleLabel.textColor = UIColor.label
        self.subtitleLabel.textColor = UIColor.secondaryLabel
        self.heartImageView.tintColor = EventPackageConfiguration.accentColor
        
    }
    
}

#endif
