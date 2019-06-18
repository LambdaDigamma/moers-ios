//
//  ViewFactory.swift
//  Moers
//
//  Created by Lennart Fischer on 26.06.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import MapKit
import TextFieldEffects
import WebKit
import TagListView
import MMUI

extension ViewFactory {
    
    static func paddingLabel() -> PaddingLabel {
        
        let paddingLabel = PaddingLabel()
        
        paddingLabel.translatesAutoresizingMaskIntoConstraints = false
        
        return paddingLabel
        
    }
    
    static func textField() -> HoshiTextField {
        
        let textField = HoshiTextField()
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        return textField
        
    }
    
    static func webView() -> WKWebView {

        let webView = WKWebView()
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        return webView

    }
    
    static func cardView() -> CardView {
        
        let cardView = CardView()
        
        cardView.translatesAutoresizingMaskIntoConstraints = false
        
        return cardView
        
    }
    
    static func onboardingProgressView() -> OnboardingProgressView {
        
        let progressView = OnboardingProgressView()
        
        progressView.translatesAutoresizingMaskIntoConstraints = false
        
        return progressView
        
    }
    
    static func tagListView() -> TagListView {
        
        let tagListView = TagListView()
        
        tagListView.translatesAutoresizingMaskIntoConstraints = false
        tagListView.paddingX = 12
        tagListView.paddingY = 7
        tagListView.marginX = 10
        tagListView.marginY = 7
        tagListView.removeIconLineWidth = 2
        tagListView.removeButtonIconSize = 7
        tagListView.textFont = UIFont.boldSystemFont(ofSize: 10)
        tagListView.cornerRadius = 10
        tagListView.backgroundColor = UIColor.clear
        
        return tagListView
        
    }
    
    static func checkmarkView() -> CheckmarkView {
        
        let checkmarkView = CheckmarkView()
        
        checkmarkView.translatesAutoresizingMaskIntoConstraints = false
        
        return checkmarkView
        
    }
    
    static func organisationHeader() -> OrganisationHeader {
        
        let header = OrganisationHeader()
        
        header.translatesAutoresizingMaskIntoConstraints = false
        
        return header
        
    }
    
}
