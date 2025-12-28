//
//  AboutViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 21.05.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Core
import SwiftUI
import StoreKit
import SafariServices

class AboutViewController: DefaultHostingController {
    
    override func hostView() -> AnyView {
        return AboutScreen(onOpenReview: openManualReview, onOpenDeveloperLink: openDeveloperLink(link:)).toAnyView()
    }
    
    public func openManualReview() {
        
        guard let writeReviewURL = URL(
            string: "https://apps.apple.com/app/id\(Constants.appStoreID)?action=write-review"
        ) else { fatalError("Expected a valid URL") }
        
        UIApplication.shared.open(writeReviewURL, options: [:], completionHandler: nil)
        
    }
    
    public func openDeveloperLink(link: DeveloperLinkType) {
        
        switch link {
            case .website:
                pushWebController(url: "https://lambdadigamma.com")
                break
            case .twitter:
                pushWebController(url: "https://twitter.com/lambdadigamma")
            case .instagram:
                pushWebController(url: "https://lambdadigamma.com")
        }
        
    }
    
    private func pushWebController(url: String) {
        
        guard let url = URL(string: url) else { fatalError("Expected a valid URL") }
        
        let configuration = SFSafariViewController.Configuration()
        let viewController = SFSafariViewController(url: url, configuration: configuration)
        
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
}

class OldAboutViewController: UIViewController {

    lazy var cfnImageView: UIImageView = {
        
        let imageView = UIImageView()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = #imageLiteral(resourceName: "cfn")
        
        return imageView
        
    }()
    
    lazy var cfnLabel: UILabel = {
        
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 21)
        label.text = "CodeForNiederrhein"
        
        return label
        
    }()
    
    lazy var cfnTextView: UITextView = {
        
        let textView = UITextView()
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.boldSystemFont(ofSize: 14)
        textView.text = "Twitter: twitter.com/codefornrn\nWebsite: codeforniederrhein.de"
        textView.isEditable = false
        textView.isSelectable = true
        textView.dataDetectorTypes = .all
        
        return textView
        
    }()
    
    lazy var meAvatarImageView: UIImageView = {
        
        let imageView = UIImageView()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = #imageLiteral(resourceName: "avatar")
        
        return imageView
        
    }()
    
    lazy var nameLabel: UILabel = {
        
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.boldSystemFont(ofSize: 21)
        label.text = "Lennart Fischer"
        
        return label
        
    }()
    
    lazy var meTextView: UITextView = {
        
        let textView = UITextView()
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.boldSystemFont(ofSize: 14)
        textView.text = "Twitter: twitter.com/lambdadigamma\nWebsite: lambdadigamma.com"
        textView.isEditable = false
        textView.isSelectable = true
        textView.dataDetectorTypes = .all
        
        return textView
        
    }()
    
    lazy var infoTextView: UITextView = {
        
        let textView = UITextView()
        
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.font = UIFont.preferredFont(forTextStyle: .body, compatibleWith: .current) // UIFont.boldSystemFont(ofSize: 14)
        textView.text = String(localized:
"""
Diese App ist ein Projekt der Gruppe Code for Niederrhein und wurde von Lennart Fischer entwickelt. 
Die Daten stammen aus dem OpenData-Portal der Stadt Moers (offenesdatenportal.de) und die 360° Panoramen werden von der Moerser Firma Telepano (telepano.de) zur Verfügung gestellt.

Sie vermissen Ihr Geschäft in dieser App, Daten sind nicht aktuell oder wollen Feedback geben?
Kein Problem: Schreiben Sie einfach eine Email an moersapp@lambdadigamma.com!

Alle Angaben zu Daten sind ohne Gewähr.
""")

        textView.isEditable = false
        
        return textView
        
    }()
    
    // MARK: - UIViewController Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.setupConstraints()
        self.setupTheming()
        
    }
    
    // MARK: - Setup -
    
    private func setupUI() {
        
        self.title = String(localized: "About")
        
        self.view.addSubview(cfnImageView)
        self.view.addSubview(cfnLabel)
        self.view.addSubview(cfnTextView)
        self.view.addSubview(meAvatarImageView)
        self.view.addSubview(nameLabel)
        self.view.addSubview(meTextView)
        self.view.addSubview(infoTextView)
        
    }
    
    private func setupConstraints() {
        
        let constraints: [NSLayoutConstraint] = [
            cfnImageView.widthAnchor.constraint(equalToConstant: 70),
            cfnImageView.heightAnchor.constraint(equalTo: cfnImageView.widthAnchor),
            cfnImageView.topAnchor.constraint(equalTo: self.safeTopAnchor, constant: 16),
            cfnImageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            cfnLabel.topAnchor.constraint(equalTo: self.safeTopAnchor, constant: 16),
            cfnLabel.leadingAnchor.constraint(equalTo: cfnImageView.trailingAnchor, constant: 8),
            cfnLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            cfnTextView.topAnchor.constraint(equalTo: cfnLabel.bottomAnchor),
            cfnTextView.leadingAnchor.constraint(equalTo: cfnImageView.trailingAnchor, constant: 4),
            cfnTextView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            cfnTextView.heightAnchor.constraint(equalToConstant: 50),
            meAvatarImageView.widthAnchor.constraint(equalTo: cfnImageView.widthAnchor),
            meAvatarImageView.heightAnchor.constraint(equalTo: meAvatarImageView.widthAnchor),
            meAvatarImageView.topAnchor.constraint(equalTo: cfnImageView.bottomAnchor, constant: 16),
            meAvatarImageView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            nameLabel.topAnchor.constraint(equalTo: meAvatarImageView.topAnchor, constant: 0),
            nameLabel.leadingAnchor.constraint(equalTo: meAvatarImageView.trailingAnchor, constant: 8),
            nameLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            meTextView.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            meTextView.leadingAnchor.constraint(equalTo: meAvatarImageView.trailingAnchor, constant: 4),
            meTextView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            meTextView.heightAnchor.constraint(equalToConstant: 50),
            infoTextView.topAnchor.constraint(equalTo: meTextView.bottomAnchor, constant: 16),
            infoTextView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
            infoTextView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
            infoTextView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -16)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        self.view.backgroundColor = UIColor.systemBackground
        self.cfnLabel.textColor = UIColor.label
        self.cfnTextView.textColor = UIColor.label
        self.cfnTextView.backgroundColor = .clear
        self.nameLabel.textColor = UIColor.label
        self.meTextView.textColor = UIColor.label
        self.meTextView.backgroundColor = .clear
        self.infoTextView.textColor = UIColor.label
        self.infoTextView.backgroundColor = .clear
    }
    
}
