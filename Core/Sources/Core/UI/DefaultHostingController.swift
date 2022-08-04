//
//  DefaultHostingController.swift
//  
//
//  Created by Lennart Fischer on 23.05.22.
//

#if canImport(UIKit)

import UIKit
import SwiftUI

open class DefaultHostingController: UIViewController {
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    /// It is not really recommended to use `AnyView` but here it
    /// is a good and working solution for this problem.
    /// There may be a different solution but investigating takes
    /// too much time at the moment. todo.
    @ViewBuilder open func hostView() -> AnyView {
        Text("Hosting")
            .toAnyView()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        
        self.addSubSwiftUIView(hostView(), to: view)
        
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

public extension View {
    
    func toAnyView() -> AnyView {
        return AnyView(self)
    }
    
}

#endif
