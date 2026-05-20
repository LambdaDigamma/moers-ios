//
//  DebugFCMTokenViewController.swift
//  moers festival
//
//  Created by Codex on 19.05.26.
//  Copyright © 2026 Code for Niederrhein. All rights reserved.
//

import FirebaseMessaging
import UIKit

final class DebugFCMTokenViewController: UIViewController {

    private let statusLabel = UILabel()
    private let tokenTextView = UITextView()
    private let copyButton = UIButton(type: .system)
    private let refreshButton = UIButton(type: .system)

    private var currentToken: String?

    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        refreshToken()
    }

    private func setupUI() {
        title = "FCM Token"
        view.backgroundColor = .systemGroupedBackground

        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        statusLabel.font = .preferredFont(forTextStyle: .body)
        statusLabel.adjustsFontForContentSizeCategory = true
        statusLabel.textColor = .secondaryLabel
        statusLabel.numberOfLines = 0

        tokenTextView.translatesAutoresizingMaskIntoConstraints = false
        tokenTextView.backgroundColor = .secondarySystemGroupedBackground
        tokenTextView.font = .preferredFont(forTextStyle: .footnote)
        tokenTextView.adjustsFontForContentSizeCategory = true
        tokenTextView.isEditable = false
        tokenTextView.isSelectable = true
        tokenTextView.layer.cornerRadius = 10
        tokenTextView.layer.cornerCurve = .continuous
        tokenTextView.textContainerInset = UIEdgeInsets(top: 12, left: 10, bottom: 12, right: 10)
        tokenTextView.accessibilityIdentifier = "DebugFCMTokenTextView"

        copyButton.setTitle("Copy", for: .normal)
        copyButton.addTarget(self, action: #selector(copyToken), for: .touchUpInside)
        copyButton.accessibilityIdentifier = "DebugFCMTokenCopyButton"

        refreshButton.setTitle("Refresh", for: .normal)
        refreshButton.addTarget(self, action: #selector(refreshToken), for: .touchUpInside)
        refreshButton.accessibilityIdentifier = "DebugFCMTokenRefreshButton"

        let buttonStack = UIStackView(arrangedSubviews: [copyButton, refreshButton])
        buttonStack.translatesAutoresizingMaskIntoConstraints = false
        buttonStack.axis = .horizontal
        buttonStack.alignment = .fill
        buttonStack.distribution = .fillEqually
        buttonStack.spacing = 12

        let contentStack = UIStackView(arrangedSubviews: [statusLabel, tokenTextView, buttonStack])
        contentStack.translatesAutoresizingMaskIntoConstraints = false
        contentStack.axis = .vertical
        contentStack.spacing = 16
        contentStack.setCustomSpacing(24, after: tokenTextView)

        view.addSubview(contentStack)

        NSLayoutConstraint.activate([
            contentStack.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            contentStack.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            contentStack.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),

            tokenTextView.heightAnchor.constraint(greaterThanOrEqualToConstant: 180)
        ])

        applyLoadingState()
    }

    @objc private func copyToken() {
        guard let currentToken else { return }

        UIPasteboard.general.string = currentToken
        statusLabel.text = "Token copied."
    }

    @objc private func refreshToken() {
        applyLoadingState()

        Messaging.messaging().token { [weak self] token, error in
            let errorMessage = error?.localizedDescription

            DispatchQueue.main.async {
                self?.applyTokenResult(token: token, errorMessage: errorMessage)
            }
        }
    }

    private func applyLoadingState() {
        currentToken = nil
        statusLabel.text = "Loading FCM token..."
        tokenTextView.text = ""
        copyButton.isEnabled = false
        refreshButton.isEnabled = false
    }

    private func applyTokenResult(token: String?, errorMessage: String?) {
        refreshButton.isEnabled = true

        if let errorMessage {
            currentToken = nil
            statusLabel.text = "Could not load FCM token: \(errorMessage)"
            tokenTextView.text = ""
            copyButton.isEnabled = false
            return
        }

        guard let token, token.isEmpty == false else {
            currentToken = nil
            statusLabel.text = "No FCM token is currently available."
            tokenTextView.text = ""
            copyButton.isEnabled = false
            return
        }

        currentToken = token
        statusLabel.text = "Current FCM token:"
        tokenTextView.text = token
        copyButton.isEnabled = true
    }

}
