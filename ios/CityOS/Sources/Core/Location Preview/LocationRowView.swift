//
//  LocationRowView.swift
//  MMUI
//
//  Created by Lennart Fischer on 25.06.19.
//  Copyright © 2019 LambdaDigamma. All rights reserved.
//

import UIKit
import Combine

public class LocationRowView: UIView {
    
    public var location: CurrentValueSubject<String?, Never> = CurrentValueSubject("")
    public var isEnabled: CurrentValueSubject<Bool, Never> = CurrentValueSubject(true)
    
    // MARK: - UI
    
    private lazy var topSeparator = { CoreViewFactory.separatorView() }()
    private lazy var imageView = { CoreViewFactory.imageView() }()
    private lazy var locationHeader = { CoreViewFactory.label() }()
    private lazy var locationLabel = { CoreViewFactory.label() }()
    private lazy var detailDisclosure = { CoreViewFactory.detailDisclosureView() }()
    private lazy var bottomSeparator = { CoreViewFactory.separatorView() }()
    
    private var cancellables = Set<AnyCancellable>()
    private let mapWidth: CGFloat = 50
    
    init(location: String) {
        self.location.value = location
        super.init(frame: .zero)
        self.setupUI()
        self.setupConstraints()
        self.setupTheming()
        self.bindData()
        self.setupAccessibility()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        
        self.addSubview(imageView)
        self.addSubview(locationHeader)
        self.addSubview(locationLabel)
        self.addSubview(detailDisclosure)
        
        self.layer.cornerRadius = 8
        
        self.imageView.layer.cornerRadius = mapWidth / 2
        self.imageView.clipsToBounds = true
        self.imageView.image = UIImage(
            named: "marker",
            in: Bundle(for: LocationRowView.self),
            compatibleWith: nil
        )?.withRenderingMode(.alwaysTemplate)
        
        self.locationHeader.font = UIFont.systemFont(ofSize: 20, weight: .semibold)
        self.locationLabel.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        
        self.locationHeader.numberOfLines = 0
        self.locationLabel.numberOfLines = 0
        
        self.locationHeader.text = String(localized: "Venue", bundle: .module)
        
    }
    
    private func setupConstraints() {
        
        let contentConstraints: [NSLayoutConstraint] = [
            imageView.centerYAnchor.constraint(equalTo: centerYAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            imageView.widthAnchor.constraint(equalToConstant: mapWidth),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
            locationHeader.topAnchor.constraint(equalTo: self.topAnchor, constant: 12),
            locationHeader.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 16),
            locationHeader.trailingAnchor.constraint(equalTo: detailDisclosure.leadingAnchor, constant: -8),
            locationLabel.topAnchor.constraint(equalTo: locationHeader.bottomAnchor, constant: 4),
            locationLabel.leadingAnchor.constraint(equalTo: locationHeader.leadingAnchor),
            locationLabel.trailingAnchor.constraint(equalTo: detailDisclosure.leadingAnchor, constant: -8),
            locationLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -12),
            detailDisclosure.topAnchor.constraint(equalTo: locationHeader.topAnchor),
            detailDisclosure.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            detailDisclosure.bottomAnchor.constraint(equalTo: locationLabel.bottomAnchor),
            detailDisclosure.widthAnchor.constraint(equalToConstant: 20)
        ]
        
        [
            contentConstraints
        ].forEach { NSLayoutConstraint.activate($0) }
        
    }
    
    private func setupTheming() {
        
        self.locationHeader.textColor = UIColor.label
        self.locationLabel.textColor = UIColor.label
        self.detailDisclosure.color = UIColor.secondaryLabel
        self.imageView.backgroundColor = UIColor.systemYellow
        
#if !os(tvOS)
        self.detailDisclosure.backgroundColor = UIColor.secondarySystemBackground
        self.imageView.tintColor = UIColor.systemBackground
        self.backgroundColor = UIColor.secondarySystemBackground
#endif
        
        
    }
    
    private func setupAccessibility() {
        
        self.isAccessibilityElement = true
        self.accessibilityIdentifier = "LocationRow"
        
        self.locationHeader.accessibilityIdentifier = "LocationRow.LocationHeader"
        self.locationLabel.accessibilityIdentifier = "LocationRow.LocationLabel"
        self.imageView.accessibilityIdentifier = "LocationRow.LocationImage"
        
        self.location
            .map { "\(String(localized: "Venue", bundle: .module)): \($0 ?? String(localized: "Unknown", bundle: .module))" }
            .sink { (accessibilityLabel: String?) in
                self.accessibilityLabel = accessibilityLabel
            }
            .store(in: &cancellables)
    }
    
    private func bindData() {
        
        self.location.assign(to: \.text, on: locationLabel).store(in: &cancellables)
        
        self.isEnabled.sink { (isEnabled: Bool) in
            
            self.isUserInteractionEnabled = isEnabled
            self.locationHeader.alpha = isEnabled ? 1.0 : 0.35
            self.locationLabel.alpha = isEnabled ? 1.0 : 0.35
            self.detailDisclosure.isHidden = !isEnabled
            self.accessibilityTraits = isEnabled ? [.button] : [.notEnabled]
            
        }
        .store(in: &cancellables)
        
    }
    
}
