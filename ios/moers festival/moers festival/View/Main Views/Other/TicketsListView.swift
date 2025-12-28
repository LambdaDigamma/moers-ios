//
//  TicketsListView.swift
//  moers festival
//
//  Created by Lennart Fischer on 15.04.19.
//  Copyright © 2019 CodeForNiederrhein. All rights reserved.
//

import UIKit

class TicketsListView: UIView {
    
    // MARK: - Properties
    
    private let viewModel: TicketsListViewModel
    
    init(viewModel: TicketsListViewModel, buyAction: ((TicketViewModel) -> Void)? = nil) {
        self.viewModel = viewModel
        self.buyAction = buyAction
        super.init(frame: .zero)
        self.setupUI()
        self.setupConstraints()
        self.setupDateTickets()
        self.setupMoerzzTickets()
        self.setupTheming()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI
    
    public var buyAction: ((TicketViewModel) -> Void)? {
        didSet {
            mainTicketView.onBuy = buyAction
            vipTicketView.onBuy = buyAction
            earlyBirdTicketView.onBuy = buyAction
            dayTicketViews.forEach { $0.onBuy = buyAction }
            moerzzTicketViews.forEach { $0.onBuy = buyAction }
        }
    }
    
    private lazy var scrollView = { ViewFactory.scrollView() }()
    private lazy var contentView = { ViewFactory.blankView() }()
    private lazy var earlyBirdTicketView = { ViewFactory.ticketView(viewModel: TicketViewModel(ticket: viewModel.ticket(for: .earlyBirdTicket))) }()
    private lazy var mainTicketView = { ViewFactory.ticketView(viewModel: TicketViewModel(ticket: viewModel.ticket(for: .mainTicket))) }()
    private lazy var daysCarousselView = { ViewFactory.scrollView() }()
    private lazy var daysStackView = { ViewFactory.stackView() }()
    private lazy var daysPageControl = { UIPageControl() }()
    private lazy var moerzzCarousselView = { ViewFactory.scrollView() }()
    private lazy var moerzzStackView = { ViewFactory.stackView() }()
    private lazy var moerzzPageControl = { UIPageControl() }()
    private lazy var vipTicketView = { ViewFactory.ticketView(viewModel: TicketViewModel(ticket: viewModel.ticket(for: .vipTicket))) }()
    private lazy var infoTicketView = { ViewFactory.label() }()
    private lazy var infoLabel = { ViewFactory.label() }()
    private var dayTicketViews: [TicketView] = []
    private var moerzzTicketViews: [TicketView] = []
    
    private func setupUI() {
        
        self.addSubview(scrollView)
        self.scrollView.addSubview(contentView)
//        self.contentView.addSubview(earlyBirdTicketView)
        self.contentView.addSubview(mainTicketView)
        
        self.contentView.addSubview(daysCarousselView)
        self.contentView.addSubview(daysPageControl)
        self.daysCarousselView.addSubview(daysStackView)
        
        self.contentView.addSubview(moerzzCarousselView)
        self.contentView.addSubview(moerzzPageControl)
        self.moerzzCarousselView.addSubview(moerzzStackView)
        
        self.contentView.addSubview(vipTicketView)
        self.contentView.addSubview(infoLabel)
        
        self.scrollView.showsVerticalScrollIndicator = false
        
        self.daysCarousselView.isPagingEnabled = true
        self.daysCarousselView.showsHorizontalScrollIndicator = false
        self.daysCarousselView.delegate = self
        
        self.moerzzCarousselView.isPagingEnabled = true
        self.moerzzCarousselView.showsHorizontalScrollIndicator = false
        self.moerzzCarousselView.delegate = self
        
        self.daysStackView.distribution = .equalSpacing
        self.daysStackView.spacing = 0 // TODO: Fix this spacing error.
        
        self.moerzzStackView.distribution = .equalSpacing
        self.moerzzStackView.spacing = 0
        
        self.infoLabel.numberOfLines = 0
        self.infoLabel.font = UIFont.systemFont(ofSize: 12)
        self.infoLabel.text = String.localized("TicketInfo")
        
        self.mainTicketView.onBuy = buyAction
        self.earlyBirdTicketView.onBuy = buyAction
        self.vipTicketView.onBuy = buyAction
        
    }
    
    private func setupConstraints() {
        
        let margins = self.readableContentGuide
        
        let horizontalSpacing: CGFloat = 0
        
        let constraints = [
            scrollView.topAnchor.constraint(equalTo: self.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: self.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: self.safeAreaLayoutGuide.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: margins.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: margins.trailingAnchor),
            contentView.topAnchor.constraint(equalTo: self.scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: margins.widthAnchor),
            mainTicketView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            mainTicketView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: horizontalSpacing),
            mainTicketView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -horizontalSpacing),
            daysStackView.topAnchor.constraint(equalTo: daysCarousselView.topAnchor, constant: 0),
            daysStackView.leftAnchor.constraint(equalTo: daysCarousselView.leftAnchor, constant: horizontalSpacing),
            daysStackView.rightAnchor.constraint(equalTo: daysCarousselView.rightAnchor, constant: -horizontalSpacing),
            daysStackView.bottomAnchor.constraint(equalTo: daysCarousselView.bottomAnchor, constant: 0),
            daysStackView.heightAnchor.constraint(equalToConstant: 412),
            daysCarousselView.topAnchor.constraint(equalTo: mainTicketView.bottomAnchor, constant: 20),
            daysCarousselView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 0),
            daysCarousselView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 0),
            daysCarousselView.heightAnchor.constraint(equalToConstant: 412),
            daysPageControl.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            daysPageControl.topAnchor.constraint(equalTo: daysCarousselView.bottomAnchor, constant: 0),
            moerzzStackView.topAnchor.constraint(equalTo: moerzzCarousselView.topAnchor, constant: 0),
            moerzzStackView.leftAnchor.constraint(equalTo: moerzzCarousselView.leftAnchor, constant: horizontalSpacing),
            moerzzStackView.rightAnchor.constraint(equalTo: moerzzCarousselView.rightAnchor, constant: -horizontalSpacing),
            moerzzStackView.bottomAnchor.constraint(equalTo: moerzzCarousselView.bottomAnchor, constant: 0),
            moerzzStackView.heightAnchor.constraint(equalToConstant: 412),
            moerzzCarousselView.topAnchor.constraint(equalTo: daysPageControl.bottomAnchor, constant: 20),
            moerzzCarousselView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 0),
            moerzzCarousselView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: 0),
            moerzzCarousselView.heightAnchor.constraint(equalToConstant: 412),
            moerzzPageControl.centerXAnchor.constraint(equalTo: self.contentView.centerXAnchor),
            moerzzPageControl.topAnchor.constraint(equalTo: moerzzCarousselView.bottomAnchor, constant: 0),
            vipTicketView.topAnchor.constraint(equalTo: moerzzPageControl.bottomAnchor, constant: 20),
            vipTicketView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: horizontalSpacing),
            vipTicketView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -horizontalSpacing),
            infoLabel.topAnchor.constraint(equalTo: vipTicketView.bottomAnchor, constant: 20),
            infoLabel.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: horizontalSpacing),
            infoLabel.rightAnchor.constraint(equalTo: vipTicketView.rightAnchor, constant: -horizontalSpacing),
            infoLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        self.backgroundColor = UIColor.systemBackground
        self.infoLabel.textColor = UIColor.secondaryLabel
        
    }
    
    // Day Tickets
    
    private func setupDateTickets() {
        
        for i in 1...4 {
            dayTicketViews.append(setupDayTicketView(for: i))
        }
        
        dayTicketViews.forEach { (view) in
            view.translatesAutoresizingMaskIntoConstraints = false
            daysStackView.addArrangedSubview(view)
            view.heightAnchor.constraint(equalToConstant: 412).isActive = true
            view.widthAnchor.constraint(equalTo: self.mainTicketView.widthAnchor).isActive = true
        }
        
        daysPageControl.translatesAutoresizingMaskIntoConstraints = false
        daysPageControl.numberOfPages = dayTicketViews.count
        daysPageControl.addTarget(self, action: #selector(pageControlTapped(sender:)), for: .valueChanged)
        
    }
    
    private func setupMoerzzTickets() {
        
        for i in 1...4 {
            moerzzTicketViews.append(setupMoerzzTicketView(for: i))
        }
        
        moerzzTicketViews.forEach { (view) in
            view.translatesAutoresizingMaskIntoConstraints = false
            moerzzStackView.addArrangedSubview(view)
            view.heightAnchor.constraint(equalToConstant: 412).isActive = true
            view.widthAnchor.constraint(equalTo: self.mainTicketView.widthAnchor).isActive = true
        }
        
        moerzzPageControl.translatesAutoresizingMaskIntoConstraints = false
        moerzzPageControl.numberOfPages = dayTicketViews.count
        moerzzPageControl.addTarget(self, action: #selector(pageControlTapped(sender:)), for: .valueChanged)
        
    }
    
    private func setupDayTicketView(for day: Int) -> TicketView {
        
        let ticketView = ViewFactory.ticketView(viewModel: TicketViewModel(ticket: viewModel.ticket(for: .dayTicket(day: day))))
        
        ticketView.onBuy = buyAction
        
        return ticketView
        
    }
    
    private func setupMoerzzTicketView(for day: Int) -> TicketView {
        
        let ticketView = ViewFactory.ticketView(viewModel: TicketViewModel(ticket: viewModel.ticket(for: .moerzzTicket(day: day))))
        
        ticketView.onBuy = buyAction
        
        return ticketView
        
    }
    
    // MARK: - Actions
    
    @objc func pageControlTapped(sender: UIPageControl) {
        
        let pageWidth = daysCarousselView.bounds.width
        let offset = sender.currentPage * Int(pageWidth)
        
        if sender === daysPageControl {
            
            UIView.animate(withDuration: 0.33, animations: { [weak self] in
                self?.daysCarousselView.contentOffset.x = CGFloat(offset)
            })
            
        } else if sender === moerzzPageControl {
            
            UIView.animate(withDuration: 0.33, animations: { [weak self] in
                self?.moerzzCarousselView.contentOffset.x = CGFloat(offset)
            })
            
        }
        
    }
    
}

extension TicketsListView: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let pageWidth = scrollView.bounds.width
        let pageFraction = scrollView.contentOffset.x / pageWidth
        
        if scrollView === daysCarousselView {
            daysPageControl.currentPage = Int((round(pageFraction)))
        } else if scrollView === moerzzCarousselView {
            moerzzPageControl.currentPage = Int((round(pageFraction)))
        }
        
    }
    
}
