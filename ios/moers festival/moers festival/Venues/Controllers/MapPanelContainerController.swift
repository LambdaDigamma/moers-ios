import UIKit

final class MapPanelContainerController: UIViewController {
    
    var topBoundaryProvider: (() -> CGFloat)?
    var onBaseStateChange: ((MapPanelState) -> Void)?
    var onDetailClose: (() -> Void)?
    
    private let panelInset: CGFloat = 16
    private let preferredPanelWidth: CGFloat = 380
    private let peekHeight: CGFloat = 96
    private let baseChromeHeight: CGFloat = 24
    private let detailChromeHeight: CGFloat = 56
    
    private let panelView = UIView()
    private let materialView = UIVisualEffectView()
    private let tintView = UIView()
    private let chromeView = UIView()
    private let grabberView = UIView()
    private let closeButton = UIButton(type: .system)
    private let contentContainerView = UIView()
    
    private var panelWidthConstraint: NSLayoutConstraint!
    private var panelHeightConstraint: NSLayoutConstraint!
    private var chromeHeightConstraint: NSLayoutConstraint!
    
    private var baseController: UIViewController?
    private var detailController: UIViewController?
    private(set) var baseState: MapPanelState = .peek
    private var storedBaseState: MapPanelState = .peek
    private var panStartingHeight: CGFloat = 0
    
    private lazy var panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(handlePanelPan(_:)))
    
    override func loadView() {
        view = MapPanelPassthroughView()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupConstraints()
        applyBaseChrome()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard traitCollection.hasDifferentColorAppearance(comparedTo: previousTraitCollection) else { return }
        updatePanelAppearance()
    }
    
    func installBasePanel(with controller: UIViewController, initialState: MapPanelState) {
        
        guard baseController == nil else { return }
        
        baseController = controller
        embed(controller, in: contentContainerView)
        controller.view.backgroundColor = .clear
        storedBaseState = initialState
        setBasePanelState(initialState, animated: false)
    }
    
    func setBasePanelState(_ state: MapPanelState, animated: Bool) {
        
        baseState = state
        storedBaseState = state
        onBaseStateChange?(state)
        
        guard detailController == nil else { return }
        
        applyBaseChrome()
        invalidatePanelLayout(animated: animated)
    }

    func releasePanels() {
        for child in children {
            child.view.layer.removeAllAnimations()
            child.view.alpha = 1
            child.view.transform = .identity
            child.view.isHidden = false
            remove(child)
        }
        baseController = nil
        detailController = nil
    }

    func dismissDetailPanel() {
        closeDetailPanel()
    }
    
    func showDetailPanel(with controller: UIViewController, animated: Bool) {
        
        if let existingDetail = detailController {
            remove(existingDetail)
        }
        
        if detailController == nil {
            storedBaseState = baseState
        }
        
        detailController = controller
        controller.view.backgroundColor = .clear
        baseController?.view.isHidden = true
        embed(controller, in: contentContainerView)
        applyDetailChrome()
        invalidatePanelLayout(animated: animated)
        
        guard animated else { return }
        
        controller.view.alpha = 0
        controller.view.transform = CGAffineTransform(translationX: 0, y: 32)
        
        UIView.animate(withDuration: 0.24, delay: 0, options: [.curveEaseOut]) {
            controller.view.alpha = 1
            controller.view.transform = .identity
        }
    }
    
    func invalidatePanelLayout(animated: Bool) {
        
        let availableWidth = view.bounds.width - view.safeAreaInsets.left - view.safeAreaInsets.right - (panelInset * 2)
        panelWidthConstraint.constant = min(preferredPanelWidth, max(280, availableWidth))
        
        if detailController != nil {
            panelHeightConstraint.constant = expandedHeight()
            chromeHeightConstraint.constant = detailChromeHeight
        } else {
            panelHeightConstraint.constant = baseState == .peek ? peekHeight : expandedHeight()
            chromeHeightConstraint.constant = baseChromeHeight
        }
        
        let animations = {
            self.view.layoutIfNeeded()
        }
        
        if animated {
            UIView.animate(withDuration: 0.28, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0.2, options: [.curveEaseInOut], animations: animations)
        } else {
            animations()
        }
    }
    
    private func setupUI() {
        
        view.backgroundColor = .clear
        
        panelView.translatesAutoresizingMaskIntoConstraints = false
        panelView.layer.cornerRadius = 28
        panelView.layer.cornerCurve = .continuous
        panelView.layer.borderWidth = 1 / self.traitCollection.displayScale
        registerForTraitChanges([UITraitDisplayScale.self]) { (self: MapPanelContainerController, _) in
            self.panelView.layer.borderWidth = 1 / self.traitCollection.displayScale
        }
        panelView.layer.shadowRadius = 24
        panelView.layer.shadowOffset = CGSize(width: 0, height: 12)
        panelView.clipsToBounds = true
        
        materialView.translatesAutoresizingMaskIntoConstraints = false
        
        tintView.translatesAutoresizingMaskIntoConstraints = false
        
        chromeView.translatesAutoresizingMaskIntoConstraints = false
        chromeView.backgroundColor = .clear
        chromeView.addGestureRecognizer(panGestureRecognizer)
        
        grabberView.translatesAutoresizingMaskIntoConstraints = false
        grabberView.layer.cornerRadius = 2.5
        
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.layer.cornerRadius = 20
        closeButton.layer.cornerCurve = .continuous
        closeButton.setImage(UIImage(systemName: "xmark"), for: .normal)
        closeButton.addTarget(self, action: #selector(closeDetailPanel), for: .touchUpInside)
        
        contentContainerView.translatesAutoresizingMaskIntoConstraints = false
        contentContainerView.backgroundColor = .clear
        
        view.addSubview(panelView)
        panelView.addSubview(materialView)
        panelView.addSubview(tintView)
        panelView.addSubview(chromeView)
        panelView.addSubview(contentContainerView)
        chromeView.addSubview(grabberView)
        chromeView.addSubview(closeButton)
        
        (view as? MapPanelPassthroughView)?.trackedView = panelView
        
        updatePanelAppearance()
    }
    
    private func setupConstraints() {
        
        panelWidthConstraint = panelView.widthAnchor.constraint(equalToConstant: preferredPanelWidth)
        panelHeightConstraint = panelView.heightAnchor.constraint(equalToConstant: peekHeight)
        chromeHeightConstraint = chromeView.heightAnchor.constraint(equalToConstant: baseChromeHeight)
        
        NSLayoutConstraint.activate([
            panelView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: panelInset),
            panelView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -panelInset),
            panelWidthConstraint,
            panelHeightConstraint,
            
            materialView.leadingAnchor.constraint(equalTo: panelView.leadingAnchor),
            materialView.trailingAnchor.constraint(equalTo: panelView.trailingAnchor),
            materialView.topAnchor.constraint(equalTo: panelView.topAnchor),
            materialView.bottomAnchor.constraint(equalTo: panelView.bottomAnchor),
            
            tintView.leadingAnchor.constraint(equalTo: panelView.leadingAnchor),
            tintView.trailingAnchor.constraint(equalTo: panelView.trailingAnchor),
            tintView.topAnchor.constraint(equalTo: panelView.topAnchor),
            tintView.bottomAnchor.constraint(equalTo: panelView.bottomAnchor),
            
            chromeView.leadingAnchor.constraint(equalTo: panelView.leadingAnchor),
            chromeView.trailingAnchor.constraint(equalTo: panelView.trailingAnchor),
            chromeView.topAnchor.constraint(equalTo: panelView.topAnchor),
            chromeHeightConstraint,
            
            contentContainerView.leadingAnchor.constraint(equalTo: panelView.leadingAnchor),
            contentContainerView.trailingAnchor.constraint(equalTo: panelView.trailingAnchor),
            contentContainerView.topAnchor.constraint(equalTo: chromeView.bottomAnchor),
            contentContainerView.bottomAnchor.constraint(equalTo: panelView.bottomAnchor),
            
            grabberView.centerXAnchor.constraint(equalTo: chromeView.centerXAnchor),
            grabberView.topAnchor.constraint(equalTo: chromeView.topAnchor, constant: 8),
            grabberView.widthAnchor.constraint(equalToConstant: 48),
            grabberView.heightAnchor.constraint(equalToConstant: 5),
            
            closeButton.trailingAnchor.constraint(equalTo: chromeView.trailingAnchor, constant: -12),
            closeButton.topAnchor.constraint(equalTo: chromeView.topAnchor, constant: 12),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40),
        ])
    }
    
    private func applyBaseChrome() {
        grabberView.isHidden = false
        closeButton.isHidden = true
        panGestureRecognizer.isEnabled = true
    }
    
    private func applyDetailChrome() {
        grabberView.isHidden = true
        closeButton.isHidden = false
        panGestureRecognizer.isEnabled = false
    }
    
    private func updatePanelAppearance() {
        
        let isDarkMode = traitCollection.userInterfaceStyle == .dark
        
        materialView.effect = UIBlurEffect(style: isDarkMode ? .systemThinMaterialDark : .systemChromeMaterialLight)
        
        panelView.layer.borderColor = (isDarkMode
            ? UIColor.white.withAlphaComponent(0.14)
            : UIColor.black.withAlphaComponent(0.08)
        ).cgColor
        
        panelView.layer.shadowColor = UIColor.black.cgColor
        panelView.layer.shadowOpacity = isDarkMode ? 0.22 : 0.10
        
        tintView.backgroundColor = isDarkMode
            ? UIColor.secondarySystemBackground.withAlphaComponent(0.14)
            : UIColor.white.withAlphaComponent(0.05)
        
        grabberView.backgroundColor = isDarkMode
            ? UIColor.white.withAlphaComponent(0.35)
            : UIColor.secondaryLabel.withAlphaComponent(0.28)
        
        closeButton.tintColor = isDarkMode ? .white : .label
        closeButton.backgroundColor = isDarkMode
            ? UIColor.black.withAlphaComponent(0.22)
            : UIColor.systemBackground.withAlphaComponent(0.72)
    }
    
    private func expandedHeight() -> CGFloat {
        
        let topBoundary = max(topBoundaryProvider?() ?? 16, view.safeAreaInsets.top + 16)
        let safeAreaBottom = view.safeAreaInsets.bottom
        let availableHeight = view.bounds.height - safeAreaBottom - panelInset - topBoundary
        
        return max(peekHeight, availableHeight)
    }
    
    private func embed(_ child: UIViewController, in containerView: UIView) {
        
        addChild(child)
        child.view.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(child.view)
        NSLayoutConstraint.activate([
            child.view.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            child.view.trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            child.view.topAnchor.constraint(equalTo: containerView.topAnchor),
            child.view.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
        ])
        child.didMove(toParent: self)
    }
    
    private func remove(_ child: UIViewController) {
        child.willMove(toParent: nil)
        child.view.removeFromSuperview()
        child.removeFromParent()
    }
    
    @objc
    private func closeDetailPanel() {
        
        guard let detailController else { return }
        
        self.detailController = nil
        onDetailClose?()
        baseState = storedBaseState
        onBaseStateChange?(storedBaseState)
        baseController?.view.isHidden = false
        applyBaseChrome()
        invalidatePanelLayout(animated: true)
        
        UIView.animate(withDuration: 0.18, delay: 0, options: [.curveEaseIn]) {
            detailController.view.alpha = 0
            detailController.view.transform = CGAffineTransform(translationX: 0, y: 32)
        } completion: { _ in
            detailController.view.transform = .identity
            self.remove(detailController)
        }
    }
    
    @objc
    private func handlePanelPan(_ gestureRecognizer: UIPanGestureRecognizer) {
        
        guard detailController == nil else { return }
        
        let maxHeight = expandedHeight()
        
        switch gestureRecognizer.state {
        case .began:
            panStartingHeight = panelHeightConstraint.constant
            
        case .changed:
            let translation = gestureRecognizer.translation(in: view).y
            let nextHeight = panStartingHeight - translation
            panelHeightConstraint.constant = min(max(nextHeight, peekHeight), maxHeight)
            view.layoutIfNeeded()
            
        case .ended, .cancelled:
            let velocity = gestureRecognizer.velocity(in: view).y
            let midpoint = (peekHeight + maxHeight) / 2
            let nextState: MapPanelState
            
            if abs(velocity) > 300 {
                nextState = velocity < 0 ? .expanded : .peek
            } else {
                nextState = panelHeightConstraint.constant > midpoint ? .expanded : .peek
            }
            
            setBasePanelState(nextState, animated: true)
            
        default:
            break
        }
    }

    // ARC-only cleanup avoids isolated-deinit back-deployment on older runtimes.
    nonisolated deinit {}
}
