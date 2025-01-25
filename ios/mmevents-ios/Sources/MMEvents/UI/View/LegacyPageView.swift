//
//  LegacyPageView.swift
//  
//
//  Created by Lennart Fischer on 06.02.20.
//

import Core
import UIKit
import LinkPresentation
import OSLog

public let eventDetailMargin: CGFloat = 16 // UIDevice.current.userInterfaceIdiom == .phone ? 16 : 0

public class LegacyPageView: UIStackView {
    
    public var viewModel: PageViewModel? {
        didSet {
            addViewsFromViewModel()
        }
    }
    private let logger: Logger = Logger(.default)
    
    private var views: [UIView] = []
    
    // MARK: - UI
    
    public var blockViews: [UIView] = []
    
    init(viewModel: PageViewModel? = nil) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        self.setupUI()
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        self.axis = .vertical
        self.alignment = .fill
        self.spacing = 16
        
    }
    
    private func setupConstraints() {
        
        
        
    }
    
    public func addViewsFromViewModel() {
        
        guard let blocks = viewModel?.model.blocks else { return }
        
        for block in blocks {
            
            switch type(of: block).type {
                
            case .markdown:
                
                guard let block = block as? MarkdownBlock else { break }
                
                self.addMarkdownBlock(block)
                
            case .soundcloud:
                break
                
//                let soundCloudTrackView = SoundCloudTrackView()
//                soundCloudTrackView.translatesAutoresizingMaskIntoConstraints = false
//
//                addArrangedSubview(soundCloudTrackView)
                
            case .externalLink:

                guard let externalLink = block as? ExternalLinkBlock else { return }
                
                self.addLinkBlock(linkBlock: externalLink)
                
            case .unknown:
                logger.log("This block type is unknown.")
            
            }
            
        }
        
    }
    
    // MARK: - Block View Setup
    
    private func addMarkdownBlock(_ block: MarkdownBlock) {
        
        let label = PaddingLabel()
        let styledText = MMUIConfig.markdownConverter(block.text)
        
        label.textInsets = UIEdgeInsets(top: 0, left: eventDetailMargin, bottom: 0, right: eventDetailMargin)
        
        label.attributedText = styledText
        label.numberOfLines = 0
        
        addArrangedSubview(label)
        
    }
    
    private func addLinkBlock(linkBlock: ExternalLinkBlock) {
        
        guard let url = URL(string: linkBlock.url) else { return }

        if #available(iOS 13.0, *) {
            
            #if !os(tvOS)
            
            let linkView = LPLinkView(url: url)
            let provider = LPMetadataProvider()
            provider.startFetchingMetadata(for: url) { (metadata, error) in
                if let md = metadata {
                    DispatchQueue.main.async {
                        linkView.metadata = md
                        linkView.sizeToFit()
                    }
                }
            }
            
            linkView.backgroundColor = UIColor.white
            linkView.layer.cornerRadius = 10
            linkView.tintColor = UIColor.white
            
            let containerView = ContainerView(
                contentView: linkView,
                edgeInsets: UIEdgeInsets(top: 0, left: eventDetailMargin, bottom: 0, right: eventDetailMargin)
            )
            
            views.append(containerView)
            addArrangedSubview(containerView)
            
            #endif
            
        } else {
            // Fallback on earlier versions
        }
        
    }
    
}
