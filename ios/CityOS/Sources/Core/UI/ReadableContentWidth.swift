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
    
    #if !os(tvOS)
    @State private var orientation: UIDeviceOrientation = UIDevice.current.orientation
    #endif
    
    func body(content: Content) -> some View {
        #if os(tvOS)
        content.frame(maxWidth: readableWidth())
        #else
        content
            .frame(maxWidth: readableWidth(for: orientation))
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                orientation = UIDevice.current.orientation
            }
        #endif
    }
    
    #if !os(tvOS)
    private func readableWidth(for _: UIDeviceOrientation) -> CGFloat {
        readableWidth()
    }
    #endif

    private func readableWidth() -> CGFloat {
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
