//
//  PageBlockView.swift
//  
//
//  Created by Lennart Fischer on 04.04.23.
//

import SwiftUI

public struct PageBlockView: View {
    
    @EnvironmentObject private var actionTransmitter: ActionTransmitter
    
    private let pageBlock: PageBlock
    private let containerFrame: CGSize
    
    public init(pageBlock: PageBlock, containerFrame: CGSize) {
        self.pageBlock = pageBlock
        self.containerFrame = containerFrame
    }
    
    public var body: some View {
        
        switch pageBlock.blockType {
            case .text:
                BlockTextWithMediaView(block: pageBlock)
            case .imageCollection:
                ImageCollectionView(block: pageBlock)
//            case .hero:
//                HeroBlockView(block: pageBlock, frame: containerFrame)
//            case .detailText:
//                DetailTextBlockView(block: pageBlock, frame: containerFrame)
//            case .goodToKnow:
//                GoodToKnowBlockView(block: pageBlock, frame: containerFrame)
//            case .youtubeVideo:
//                YouTubeVideoBlockView(block: pageBlock, frame: containerFrame)
//            case .quizHost:
//                QuizHostBlockView(block: pageBlock, frame: containerFrame, actionTransmitter: actionTransmitter)
//            case .cta:
//                CtaBlockView(block: pageBlock, frame: containerFrame)
            default:
                EmptyView()
                
        }
        
    }
    
}
