import UIKit

final class MapPlaceHeaderView: UIView {
    private let summary = UIListContentView(configuration: .subtitleCell())
    private let actions = UIStackView()
    private let stack = UIStackView()
    var performAction: ((MapPlaceAction) -> Void)?
    var showsActions = true {
        didSet {
            guard oldValue != showsActions else { return }
            actions.isHidden = !showsActions
        }
    }
    private(set) var routeButton: UIButton?

    override init(frame: CGRect) {
        super.init(frame: frame)
        tintColor = .systemBlue
        stack.axis = .vertical
        stack.spacing = 16
        stack.translatesAutoresizingMaskIntoConstraints = false
        actions.spacing = 8
        actions.distribution = .fillEqually
        stack.addArrangedSubview(summary)
        stack.addArrangedSubview(actions)
        addSubview(stack)
        NSLayoutConstraint.activate([
            stack.topAnchor.constraint(equalTo: topAnchor),
            stack.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16),
            stack.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -16),
            stack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -8)
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(title: String, subtitle: String, symbol: String, availableActions: [MapPlaceAction]) {
        var content = UIListContentConfiguration.subtitleCell()
        content.text = title
        content.secondaryText = subtitle
        content.textProperties.font = .preferredFont(forTextStyle: .title2)
        content.textProperties.numberOfLines = 2
        content.secondaryTextProperties.numberOfLines = 2
        content.image = UIImage(systemName: symbol)
        content.imageProperties.tintColor = .tintColor
        content.imageProperties.preferredSymbolConfiguration = .init(textStyle: .title1)
        content.directionalLayoutMargins = .init(top: 8, leading: 0, bottom: 0, trailing: 0)
        summary.configuration = content
        actions.arrangedSubviews.forEach { actions.removeArrangedSubview($0); $0.removeFromSuperview() }
        routeButton = nil
        for action in availableActions {
            var configuration: UIButton.Configuration = action == .route ? .filled() : .tinted()
            configuration.baseForegroundColor = action == .route ? .white : .systemBlue
            configuration.buttonSize = .large
            configuration.imagePlacement = .top
            configuration.imagePadding = 6
            switch action {
            case .route:
                configuration.title = String(localized: "Route", bundle: .module)
                configuration.image = UIImage(systemName: "arrow.turn.up.right")
            case .call:
                configuration.title = String(localized: "Call", bundle: .module)
                configuration.image = UIImage(systemName: "phone.fill")
            case .website:
                configuration.title = String(localized: "Website", bundle: .module)
                configuration.image = UIImage(systemName: "safari")
            case .camera:
                configuration.title = String(localized: "View", bundle: .module)
                configuration.image = UIImage(systemName: "camera.fill")
            case .edit, .history: continue
            }
            let button = UIButton(configuration: configuration, primaryAction: UIAction { [weak self] _ in
                self?.performAction?(action)
            })
            button.accessibilityIdentifier = action == .route ? "MapRouteButton" : "MapPlaceAction-\(action)"
            if action == .route { routeButton = button }
            actions.addArrangedSubview(button)
        }
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        let axis: NSLayoutConstraint.Axis = traitCollection.preferredContentSizeCategory.isAccessibilityCategory || bounds.width < 340
            ? .vertical : .horizontal
        if actions.axis != axis { actions.axis = axis }
    }

    nonisolated deinit {}
}
