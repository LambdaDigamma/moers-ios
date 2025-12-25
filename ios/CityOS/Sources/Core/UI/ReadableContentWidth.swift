//
//  ReadableContentWidth.swift
//  
//
//  Created by Lennart Fischer on 05.05.23.
//

import SwiftUI
import UIKit

struct ReadableContentWidth: ViewModifier {
    private let measureViewController = UIViewController()
    
    @State private var orientation: UIDeviceOrientation = UIDevice.current.orientation
    
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: readableWidth(for: orientation))
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                orientation = UIDevice.current.orientation
            }
    }
    
    private func readableWidth(for _: UIDeviceOrientation) -> CGFloat {
        measureViewController.view.frame = UIScreen.main.bounds
        let readableContentSize = measureViewController.view.readableContentGuide.layoutFrame.size
        return readableContentSize.width
    }
}

public extension View {
    func readableContentWidth() -> some View {
        modifier(ReadableContentWidth())
    }
}
