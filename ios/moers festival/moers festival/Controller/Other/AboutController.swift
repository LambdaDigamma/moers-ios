//
//  AboutController.swift
//  moers festival
//
//  Created by Lennart Fischer on 07.12.25.
//  Copyright © 2025 Code for Niederrhein. All rights reserved.
//

import UIKit
import SwiftUI

@MainActor
class AboutController: UIViewController {

    private let hostingView: _UIHostingView<About>

    init(coordinator: OtherCoordinator) {
        self.hostingView = _UIHostingView(rootView: About(
            onOpenReview: coordinator.openReview,
            onOpenDeveloperLink: coordinator.openDeveloperLink(of:)
        ))
        super.init(nibName: nil, bundle: nil)
        self.title = String(localized: "About")
        self.navigationItem.largeTitleDisplayMode = .always
    }

    required dynamic init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemBackground

        hostingView.translatesAutoresizingMaskIntoConstraints = false
        hostingView.backgroundColor = .clear

        view.addSubview(hostingView)

        let readable = view.readableContentGuide
        let safeArea = view.safeAreaLayoutGuide

        NSLayoutConstraint.activate([
            hostingView.topAnchor.constraint(equalTo: safeArea.topAnchor),
            hostingView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor),
            hostingView.leadingAnchor.constraint(equalTo: readable.leadingAnchor),
            hostingView.trailingAnchor.constraint(equalTo: readable.trailingAnchor)
        ])
    }

}
