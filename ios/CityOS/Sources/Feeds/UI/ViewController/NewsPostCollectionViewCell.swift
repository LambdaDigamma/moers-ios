import UIKit
import Nuke
import MediaLibraryKit
import SwiftUI

final class NewsPostCollectionViewCell: UICollectionViewCell {

    private let cardView = UIView()
    private let mediaImageView = UIImageView()
    private let textStackView = UIStackView()
    private let titleLabel = UILabel()
    private let summaryLabel = UILabel()
    private var mediaAspectConstraint: NSLayoutConstraint?
    typealias ImageLoader = (URL, @escaping (UIImage?) -> Void) -> (() -> Void)

    private let imageLoader: ImageLoader
    private var cancelImageRequest: (() -> Void)?
    private var imageRequestID = UUID()

    override init(frame: CGRect) {
        self.imageLoader = Self.loadImage
        super.init(frame: frame)
        setupUI()
    }

    init(frame: CGRect, imageLoader: @escaping ImageLoader) {
        self.imageLoader = imageLoader
        super.init(frame: frame)
        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        cancelImageRequest?()
        cancelImageRequest = nil
        imageRequestID = UUID()
        mediaImageView.image = nil
        mediaImageView.isHidden = false
        titleLabel.text = nil
        titleLabel.isHidden = false
        summaryLabel.text = nil
        summaryLabel.isHidden = false
    }

    override func preferredLayoutAttributesFitting(_ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        setNeedsLayout()
        layoutIfNeeded()

        let targetSize = CGSize(width: layoutAttributes.size.width, height: UIView.layoutFittingCompressedSize.height)
        let fittedSize = contentView.systemLayoutSizeFitting(
            targetSize,
            withHorizontalFittingPriority: .required,
            verticalFittingPriority: .fittingSizeLevel
        )

        let attributes = layoutAttributes.copy() as! UICollectionViewLayoutAttributes
        attributes.size = CGSize(width: floor(layoutAttributes.size.width), height: ceil(fittedSize.height))
        return attributes
    }

    func configure(with post: Post) {
        cardView.backgroundColor = .secondarySystemBackground

        let isInstagram = post.extras?.type == "instagram"
        let title = post.title.trimmingCharacters(in: .whitespacesAndNewlines)
        let summary = post.summary.trimmingCharacters(in: .whitespacesAndNewlines)

        titleLabel.text = title
        titleLabel.isHidden = isInstagram || title.isEmpty

        summaryLabel.text = summary
        summaryLabel.numberOfLines = isInstagram ? 5 : 4
        summaryLabel.isHidden = summary.isEmpty

        configureMedia(for: post)
        accessibilityLabel = [titleLabel.text, summaryLabel.text].compactMap { $0 }.joined(separator: ", ")
    }

    private func setupUI() {
        backgroundColor = .clear
        contentView.backgroundColor = .clear

        cardView.translatesAutoresizingMaskIntoConstraints = false
        cardView.backgroundColor = .secondarySystemBackground
        cardView.layer.cornerRadius = 18
        cardView.layer.cornerCurve = .continuous
        cardView.clipsToBounds = true

        mediaImageView.translatesAutoresizingMaskIntoConstraints = false
        mediaImageView.backgroundColor = .secondarySystemFill
        mediaImageView.contentMode = .scaleAspectFill
        mediaImageView.clipsToBounds = true

        textStackView.translatesAutoresizingMaskIntoConstraints = false
        textStackView.axis = .vertical
        textStackView.alignment = .fill
        textStackView.spacing = 6

        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.font = .preferredFont(forTextStyle: .headline)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.textColor = .label
        titleLabel.numberOfLines = 3

        summaryLabel.translatesAutoresizingMaskIntoConstraints = false
        summaryLabel.font = .preferredFont(forTextStyle: .footnote)
        summaryLabel.adjustsFontForContentSizeCategory = true
        summaryLabel.textColor = .secondaryLabel
        summaryLabel.numberOfLines = 4

        contentView.addSubview(cardView)
        cardView.addSubview(mediaImageView)
        cardView.addSubview(textStackView)
        textStackView.addArrangedSubview(titleLabel)
        textStackView.addArrangedSubview(summaryLabel)

        NSLayoutConstraint.activate([
            cardView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            cardView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            cardView.topAnchor.constraint(equalTo: contentView.topAnchor),
            cardView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),

            mediaImageView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor),
            mediaImageView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor),
            mediaImageView.topAnchor.constraint(equalTo: cardView.topAnchor),

            textStackView.leadingAnchor.constraint(equalTo: cardView.leadingAnchor, constant: 16),
            textStackView.trailingAnchor.constraint(equalTo: cardView.trailingAnchor, constant: -16),
            textStackView.topAnchor.constraint(equalTo: mediaImageView.bottomAnchor, constant: 14),
            textStackView.bottomAnchor.constraint(equalTo: cardView.bottomAnchor, constant: -16)
        ])

        updateAspectRatio(to: CGSize(width: 16, height: 9))
    }

    private func configureMedia(for post: Post) {
        // Reconfiguration keeps the cell, so reuse cleanup does not run.
        cancelImageRequest?()
        cancelImageRequest = nil
        imageRequestID = UUID()
        let requestID = imageRequestID
        let imageURL: URL?
        if let videoThumbnail = post.extras?.videoThumbnails?.thumbnails.last?.link {
            imageURL = videoThumbnail
        } else if let fullURL = post.headerMedia?.fullURL {
            imageURL = URL(string: fullURL)
        } else {
            imageURL = nil
        }

        if imageURL == nil {
            mediaImageView.isHidden = true
            updateAspectRatio(to: nil)
            mediaImageView.image = nil
            return
        }

        mediaImageView.isHidden = false
        updateAspectRatio(to: post.mediaAspectRatio())
        mediaImageView.image = nil

        guard let imageURL else { return }
        cancelImageRequest = imageLoader(imageURL) { [weak self] image in
            DispatchQueue.main.async {
                guard let self, self.imageRequestID == requestID else { return }
                self.mediaImageView.image = image
            }
        }
    }

    private static func loadImage(from url: URL, completion: @escaping (UIImage?) -> Void) -> (() -> Void) {
        let task = ImagePipeline.shared.loadImage(with: url) { result in
            switch result {
            case .success(let response):
                completion(response.image)
            case .failure:
                completion(nil)
            }
        }
        return { task.cancel() }
    }

    private func updateAspectRatio(to ratio: CGSize?) {
        mediaAspectConstraint?.isActive = false
        mediaAspectConstraint = nil

        guard let ratio, ratio.width > 0, ratio.height > 0 else { return }

        let multiplier = ratio.height / ratio.width
        let constraint = mediaImageView.heightAnchor.constraint(equalTo: mediaImageView.widthAnchor, multiplier: multiplier)
        constraint.priority = .required
        constraint.isActive = true
        mediaAspectConstraint = constraint
    }

    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}
}

#Preview("News post") {
    let cell = NewsPostCollectionViewCell(frame: CGRect(x: 0, y: 0, width: 340, height: 200))
    cell.configure(with: Post.stub(withID: 42))
    return cell
}
