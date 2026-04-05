import UIKit

final class SplitDetailPlaceholderViewController: UIViewController {
    
    private let message: String
    
    init(message: String) {
        self.message = message
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .systemBackground
        
        let label = UILabel()
        label.text = message
        label.font = .preferredFont(forTextStyle: .title3)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.readableContentGuide.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.readableContentGuide.centerYAnchor),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: view.readableContentGuide.leadingAnchor),
            label.trailingAnchor.constraint(lessThanOrEqualTo: view.readableContentGuide.trailingAnchor)
        ])
    }
}