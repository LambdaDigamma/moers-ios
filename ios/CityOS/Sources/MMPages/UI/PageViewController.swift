//
//  PageViewController.swift
//  
//
//  Created by Lennart Fischer on 02.01.21.
//

#if canImport(UIKit)

import Core
import UIKit
import ModernNetworking
import Combine
import SwiftUI

public class PageViewController: UIViewController {
    
    @Published var page: UIResource<Page> = .loading
    
    var pageViewModel: PageViewModel
    var nativePageViewModel: NativePageViewModel
    
    private var pageService: PageService? = nil
    private var pageID: Page.ID? = nil
    
    private var blocks: [PageBlock] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    public var likeBarButtonItem: UIBarButtonItem?
    
    public var config: PageDisplayConfiguration = .init() {
        didSet {
            setupBarButtonItems()
        }
    }
    
    var actionTransmitter = ActionTransmitter()
    
    // MARK: - Init
    
    public init(pageID: Page.ID, pageService: PageService? = nil) {
        
        self.pageViewModel = PageViewModel(pageService: pageService, pageID: pageID)
        self.nativePageViewModel = NativePageViewModel(pageID: pageID)
        
        super.init(nibName: nil, bundle: nil)
        
        self.pageID = pageID
        self.pageService = pageService
        
        print("Page ID: \(pageID)")
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController Lifecycle
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupBarButtonItems()
        self.setupUI()
        
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        pageViewModel.loadPage()
        
    }
    
    // MARK: - UI
    
    private func setupUI() {
        
        if pageID != nil {
            
            let pageView = NativePageView(
                viewModel: nativePageViewModel,
                actionTransmitter: actionTransmitter
            )
            
            self.addSubSwiftUIView(pageView, to: view)
            
        } else {
            
#if canImport(WebKit)
            
            let pageView = PageView(viewModel: pageViewModel)
            
            self.addSubSwiftUIView(pageView, to: view)
            
#endif
            
        }
        
    }
    
    private func setupBarButtonItems() {
        
        var rightBarButtonsItems: [UIBarButtonItem] = []
        
        if config.showShare {
            rightBarButtonsItems.append(UIBarButtonItem(
                image: UIImage(systemName: "square.and.arrow.up"),
                style: .plain,
                target: self,
                action: #selector(showSharesheet)
            ))
        }
        
        if let likeStateCallback = config.likeState, config.showLike {
            
            likeBarButtonItem = UIBarButtonItem(
                image: UIImage(systemName: likeStateCallback() ? "heart.fill" : "heart"),
                style: .plain,
                target: self,
                action: #selector(toggleLike)
            )
            
            rightBarButtonsItems.append(likeBarButtonItem!)
            
        }
        
        #if !os(tvOS)
        navigationItem.largeTitleDisplayMode = .never
        #endif
        navigationItem.rightBarButtonItems = rightBarButtonsItems
        
    }
    
    // MARK: - Data Handling
    
    private func loadPage() {
        
        if let pageService = pageService, let pageID = pageID {
            
            let pageLoading = pageService.loadPage(for: pageID)
            
            pageLoading.sink { (completion: Subscribers.Completion<Error>) in
                
                switch completion {
                    case .failure(let error):
                        print(error)
                    case .finished:
                        break
                }
                
            } receiveValue: { (page: Page) in
                
                self.page = .success(page)
                
            }.store(in: &cancellables)

        }
        
    }
    
    // MARK: - Actions
    
    @objc private func showSharesheet() {
        
        #if !os(tvOS)
        
        switch pageViewModel.page {
            case .success(_):
                
                // todo: fix this
                
                break
                
//                if var slug = page.slug,
//                   let environment = pageService?.environment {
//
//                    var urlComponents = URLComponents()
//
//                    urlComponents.scheme = environment.scheme
//                    urlComponents.host = environment.host
//
//                    if !slug.hasPrefix("/") {
//                        slug = "/" + slug
//                    }
//
//                    urlComponents.path = slug
//
//                    guard let url = urlComponents.url else { return }
//
//                    let items = [url]
//                    let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
//                    present(ac, animated: true)
//
//                }
                
            default:
                break
        }
        
        #endif
        
    }
    
    @objc private func toggleLike() {
        
        if let toggleLike = config.toggleLike {
            
            let isLiked = toggleLike()
            
            if isLiked {
                likeBarButtonItem?.image = UIImage(systemName: "heart.fill")
            } else {
                likeBarButtonItem?.image = UIImage(systemName: "heart")
            }
            
        }
        
    }
    
}

#endif
