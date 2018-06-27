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

struct ViewFactory {
    
    static func blankView() -> UIView {
    
        let view = UIView()
        
        view.translatesAutoresizingMaskIntoConstraints = false
        
        return view
    
    }
    
    static func label() -> UILabel {
        
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
        
    }
    
    static func paddingLabel() -> PaddingLabel {
        
        let label = PaddingLabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
        
    }
    
    static func scrollView() -> UIScrollView {
        
        let scrollView = UIScrollView()
        
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = false
        
        return scrollView
        
    }
    
    static func map() -> MKMapView {
        
        let map = MKMapView()
        
        map.translatesAutoresizingMaskIntoConstraints = false
        
        return map
        
    }
    
    static func textField() -> HoshiTextField {
        
        let textField = HoshiTextField()
        
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        return textField
        
    }
    
    static func imageView() -> UIImageView {
        
        let imageView = UIImageView()
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        
        return imageView
        
    }
    
    static func button() -> UIButton {
        
        let button = UIButton(type: .custom)
        
        button.translatesAutoresizingMaskIntoConstraints = false
        
        return button
        
    }
    
    static func stackView() -> UIStackView {
        
        let stackView = UIStackView()
        
        stackView.translatesAutoresizingMaskIntoConstraints = false
        
        return stackView
        
    }
    
}