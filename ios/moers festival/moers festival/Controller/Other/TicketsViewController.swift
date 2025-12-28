//
//  TicketsListViewController.swift
//  moers festival
//
//  Created by Lennart Fischer on 29.04.18.
//  Copyright © 2018 CodeForNiederrhein. All rights reserved.
//

import UIKit
import SafariServices

class TicketsListViewController: UIViewController {
    
    public var coordinator: OtherCoordinator?
    
    private let viewModel: TicketsListViewModel
    private let ticketsListView: TicketsListView
    
    init(viewModel: TicketsListViewModel) {
        self.viewModel = viewModel
        self.ticketsListView = TicketsListView(viewModel: viewModel)
        super.init(nibName: nil, bundle: nil)
        self.ticketsListView.buyAction = onBuy
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController Lifecycle
    
    override func loadView() {
        view = ticketsListView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        
        AnalyticsManager.shared.logOpenTicket()
        
    }

    // MARK: - UI
    
    private func setupUI() {
        
        self.title = String.localized("TicketsTitle")
        
    }
    
    private func onBuy(ticketViewModel: TicketViewModel) {
        
        AnalyticsManager.shared.logSelectedTicket(ticketViewModel)
        
        let config = SFSafariViewController.Configuration()
        
        config.barCollapsingEnabled = true
        
        let vc = SFSafariViewController(url: ticketViewModel.url, configuration: config)
        vc.preferredBarTintColor = navigationController?.navigationBar.barTintColor
        vc.preferredControlTintColor = navigationController?.navigationBar.tintColor
        
        self.present(vc, animated: true)
        
    }
    
}
