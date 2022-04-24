//
//  ViewFactory.swift
//  
//
//  Created by Lennart Fischer on 23.04.22.
//

import UIKit
import MapKit
import WebKit
import TagListView
import MMUI
import TextFieldEffects

internal extension ViewFactory {
    
    static func webView() -> WKWebView {
        
        let webView = WKWebView()
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        
        return webView
        
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
    
    static func onboardingProgressView() -> OnboardingProgressView {
        
        let progressView = OnboardingProgressView()
        
        progressView.translatesAutoresizingMaskIntoConstraints = false
        
        return progressView
        
    }
    
    static func textField() -> HoshiTextField {
        
        let textField = HoshiTextField()
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        return textField
        
    }
    
    static func textFieldFormView() -> TextFieldFormView {
        
        let formRow = TextFieldFormView()
        
        formRow.translatesAutoresizingMaskIntoConstraints = false
        
        return formRow
        
    }
    
    
}
