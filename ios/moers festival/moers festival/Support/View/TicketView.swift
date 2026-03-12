//
//  TicketView.swift
//  moers festival
//
//  Created by Lennart Fischer on 29.04.18.
//  Copyright © 2018 CodeForNiederrhein. All rights reserved.
//

import UIKit

class TicketView: UIView {
    
    private let viewModel: TicketViewModel
    
    init(viewModel: TicketViewModel) {
        self.viewModel = viewModel
        super.init(frame: .zero)
        self.setupUI()
        self.setupConstraints()
        self.setupTheming()
        self.bindData()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UI
    
    public var onBuy: ((TicketViewModel) -> Void)?
    
    private lazy var titleLabel = { ViewFactory.label() }()
    private lazy var ticketImageView = { ViewFactory.imageView() }()
    private lazy var dateLabel = { ViewFactory.label() }()
    private var presaleLabel = { ViewFactory.label() }()
    private var boxOfficeSaleLabel = { ViewFactory.label() }()
    private var discountSaleLabel = { ViewFactory.label() }()
    private var discountBoxOfficeSaleLabel = { ViewFactory.label() }()
    private var priceStackView = { ViewFactory.stackView() }()
    private var buyButton = { ViewFactory.button() }()
    
    private func setupUI() {
        
        self.addSubview(titleLabel)
        self.addSubview(ticketImageView)
        self.addSubview(dateLabel)
        self.addSubview(priceStackView)
        self.addSubview(buyButton)
        
        self.titleLabel.font = UIFont.boldSystemFont(ofSize: 22)
        self.titleLabel.textAlignment = .center
        self.ticketImageView.contentMode = .scaleAspectFit
        self.dateLabel.font = UIFont.boldSystemFont(ofSize: 18)
        self.dateLabel.textAlignment = .center
        self.presaleLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
        self.presaleLabel.textAlignment = .center
        self.boxOfficeSaleLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
        self.boxOfficeSaleLabel.textAlignment = .center
        self.discountSaleLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
        self.discountSaleLabel.textAlignment = .center
        self.discountBoxOfficeSaleLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.regular)
        self.discountBoxOfficeSaleLabel.textAlignment = .center
        self.priceStackView.addArrangedSubview(presaleLabel)
        self.priceStackView.addArrangedSubview(boxOfficeSaleLabel)
        self.priceStackView.addArrangedSubview(discountSaleLabel)
        self.priceStackView.addArrangedSubview(discountBoxOfficeSaleLabel)
        self.priceStackView.axis = .vertical
        self.priceStackView.spacing = 4.0
        self.buyButton.layer.cornerRadius = 12
        self.buyButton.clipsToBounds = true
        self.buyButton.setTitle(String.localized("Buy"), for: .normal)
        self.buyButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        
        self.buyButton.addTarget(self, action: #selector(tappedBuyButton), for: .touchUpInside)
        
    }
    
    @objc private func tappedBuyButton() {
        self.onBuy?(self.viewModel)
    }
    
    private func bindData() {
        
        titleLabel.text = viewModel.title
        dateLabel.text = viewModel.date
        presaleLabel.text = viewModel.presale
        boxOfficeSaleLabel.text = viewModel.boxOffice
        discountSaleLabel.text = viewModel.discountSale
        discountBoxOfficeSaleLabel.text = viewModel.discountBoxOfficeSale
        ticketImageView.image = viewModel.image
        buyButton.isHidden = viewModel.buyEnabled
        
    }
    
    private func setupConstraints() {
        
        let constraints = [
            titleLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 20),
            titleLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8),
            titleLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8),
            ticketImageView.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            ticketImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            ticketImageView.heightAnchor.constraint(equalToConstant: 150),
            ticketImageView.widthAnchor.constraint(equalTo: ticketImageView.heightAnchor),
            dateLabel.topAnchor.constraint(equalTo: ticketImageView.bottomAnchor, constant: 8),
            dateLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8),
            dateLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8),
            priceStackView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 8),
            priceStackView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8),
            priceStackView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8),
            buyButton.topAnchor.constraint(equalTo: priceStackView.bottomAnchor, constant: 20),
            buyButton.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20),
            buyButton.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -20),
            buyButton.heightAnchor.constraint(equalToConstant: 50),
            buyButton.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -20)
        ]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        self.layer.cornerRadius = 12
        
        self.backgroundColor = UIColor.secondarySystemBackground
        self.titleLabel.textColor = UIColor.label
        self.dateLabel.textColor = UIColor.label
        self.presaleLabel.textColor = UIColor.secondaryLabel
        self.boxOfficeSaleLabel.textColor = UIColor.secondaryLabel
        self.discountSaleLabel.textColor = UIColor.secondaryLabel
        self.discountBoxOfficeSaleLabel.textColor = UIColor.secondaryLabel
        self.buyButton.setBackgroundColor(AppColors.navigationAccent, forState: .normal)
        self.buyButton.setTitleColor(AppColors.onAccent, for: .normal)
        
    }
    
}
