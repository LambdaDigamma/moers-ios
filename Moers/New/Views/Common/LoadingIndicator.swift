//
//  LoadingIndicator.swift
//  Moers
//
//  Created by Lennart Fischer on 02.08.20.
//  Copyright © 2020 Lennart Fischer. All rights reserved.
//

import SwiftUI

@available(iOS 13.0, *)
struct LoadingIndicator: UIViewRepresentable {
    
    typealias UIViewType = UIActivityIndicatorView
    
    let style: UIActivityIndicatorView.Style
    
    func makeUIView(context: UIViewRepresentableContext<LoadingIndicator>) -> LoadingIndicator.UIViewType {
        return UIActivityIndicatorView(style: style)
    }
    
    func updateUIView(_ view: LoadingIndicator.UIViewType, context: UIViewRepresentableContext<LoadingIndicator>) {
        view.startAnimating()
    }
    
}

@available(iOS 13.0, *)
struct LoadingIndicator_Previews: PreviewProvider {
    static var previews: some View {
        LoadingIndicator(style: .medium)
    }
}
