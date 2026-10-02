//
//  MMEventAsyncImageView.swift
//  Moers
//
//  Created by Codex on 28.06.26.
//

import UIKit
import Nuke

final class MMEventAsyncImageView: UIImageView {
    private var imageTask: ImageTask?
    private var representedURL: URL?

    func setImage(url: URL?) {
        representedURL = url
        imageTask?.cancel()
        image = nil

        guard let url else {
            backgroundColor = .tertiarySystemFill
            return
        }

        backgroundColor = .secondarySystemFill

        imageTask = ImagePipeline.shared.loadImage(with: url) { [weak self] result in
            DispatchQueue.main.async {
                guard let self, self.representedURL == url else { return }

                switch result {
                case .success(let response):
                    self.image = response.image
                    self.backgroundColor = .secondarySystemBackground
                case .failure:
                    self.image = nil
                    self.backgroundColor = .tertiarySystemFill
                }
            }
        }
    }

    func cancelImageLoad() {
        imageTask?.cancel()
        imageTask = nil
    }
    nonisolated deinit {
        imageTask?.cancel()
    }

}
