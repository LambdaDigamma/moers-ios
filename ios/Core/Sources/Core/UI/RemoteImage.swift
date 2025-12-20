//
//  RemoteImage.swift
//  Core
//
//  Created by Lennart Fischer on 23.08.25.
//

import SwiftUI
import NukeUI

public struct RemoteImage: View {
    
    private let url: URL?
    private let contentMode: ContentMode
    
    public init(url: URL?, contentMode: ContentMode = .fill) {
        self.url = url
        self.contentMode = contentMode
    }
    
    public var body: some View {
        
        LazyImage(url: url) { state in
            ResizableStatefulImage(state: state, contentMode: contentMode)
        }
        
    }
    
}

public struct ResizableStatefulImage: View {
    
    let state: any LazyImageState
    let contentMode: ContentMode
    
    public init(state: any LazyImageState, contentMode: ContentMode) {
        self.state = state
        self.contentMode = contentMode
    }
    
    public var body: some View {
        
        if let image = state.image {
            image
                .resizable()
                .aspectRatio(contentMode: contentMode)
        } else if state.error != nil {
//            Color(UIColor.secondarySystemFill)
            Color(UIColor.systemRed)
        } else {
            Color(UIColor.secondarySystemFill)
        }
        
    }
    
}

#Preview {
    RemoteImage(
        url: URL(string: "https://kean-docs.github.io/nukeui/images/nukeui-preview.png")!,
        contentMode: .fit
    )
}
