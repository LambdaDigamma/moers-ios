//
//  LFSearchViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 17.10.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit

public class LFSearchViewController: UIViewController {

    fileprivate (set) open var searchBar: UISearchBar!
    
    public var tableView: UITableView!
    
    open weak var delegate: LFSearchViewDelegate?
    
    open var dataSource: LFSearchViewDataSource?
    
    open var navigationBarClosure: ((UINavigationBar) -> Void)?
    
    internal var searchBarOffset: UIOffset {
        get {
            return self.searchBar.searchFieldBackgroundPositionAdjustment
        }
        set {
            self.searchBar.searchFieldBackgroundPositionAdjustment = newValue
        }
    }
    
    open var searchBarBackgroundColor: UIColor = LFSearchViewDefaults.searchBarColor {
        didSet {
            if searchBar != nil, let searchField = searchBar.value(forKey: "searchField") as? UITextField {
                searchField.backgroundColor = searchBarBackgroundColor
            }
        }
    }
    
    open var keyboardAppearance: UIKeyboardAppearance = .default {
        didSet {
            self.searchBar.keyboardAppearance = keyboardAppearance
        }
    }
    
    open var searchBarPlaceHolder: String = "Search" {
        didSet {
            if self.searchBar != nil {
                self.searchBar.placeholder = searchBarPlaceHolder
            }
        }
    }
    
    open var statusBarStyle: UIStatusBarStyle = .default {
        didSet {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    open var separatorColor: UIColor = UIColor.lightGray {
        didSet {
            self.tableView.separatorColor = separatorColor
        }
    }
    
    private (set) open var cellIdentifier: String = LFSearchViewDefaults.reuseIdetentifer
    
    private (set) open var cellClass: AnyClass = UITableViewCell.self
    
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        return self.statusBarStyle
    }
    
    fileprivate var didAppear = false
    
    convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    convenience init(cellReuseIdentifier cellId: String, cellReuseClass: AnyClass) {
        
        self.init()
        self.cellIdentifier = cellId
        self.cellClass = cellReuseClass
        
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - UIViewController
    
    override public func dismiss(animated flag: Bool, completion: (() -> Void)? = nil) {
        
        self.searchBar.resignFirstResponder()
        self.delegate?.searchView(self, didDismissWithText: searchBar.text!)
        super.dismiss(animated: flag, completion: completion)
        
    }
    
    open func show(
        in controller: UIViewController,
        animated: Bool = true,
        completion: (() -> Void)? = nil
    ) {
        
        let navgation = WrapperNavigationController(rootViewController: self)
        navgation.dataSource = self
        navgation.modalPresentationStyle = .overCurrentContext
        navgation.modalTransitionStyle = .crossDissolve
        navgation.modalPresentationCapturesStatusBarAppearance = true
        navigationBarClosure?(navgation.navigationBar)
        controller.present(navgation, animated: animated, completion: completion)
        
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(tableView)
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        self.view.backgroundColor = LFSearchViewDefaults.backgroundColor
        
        self.tableView.register(self.cellClass, forCellReuseIdentifier: self.cellIdentifier)
        self.tableView.tableFooterView = UIView()
        self.tableView.isHidden = false
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorInsetReference = .fromCellEdges
        self.tableView.separatorInset = UIEdgeInsets(top: 0, left: -16, bottom: 0, right: 0)
        
        self.searchBar.placeholder = self.searchBarPlaceHolder
        
        if let searchField = searchBar.value(forKey: "searchField") as? UITextField {
            searchField.backgroundColor = self.searchBarBackgroundColor
        }
        
        self.navigationItem.titleView = self.searchBar
        
        self.searchBar.delegate = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(LFSearchViewController.didTapBackground(sender:)))
        tap.delegate = self
        self.view.addGestureRecognizer(tap)
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(LFSearchViewController.keyboardWillShow(notification:)),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(LFSearchViewController.keyboardWillHide(notification:)),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.searchBar.becomeFirstResponder()
        
    }
    
    private func setup() {
        
        self.modalPresentationStyle = .overCurrentContext
        self.modalTransitionStyle = .crossDissolve
        self.modalPresentationCapturesStatusBarAppearance = true
        self.searchBar = UISearchBar()
        self.tableView = UITableView()
        
    }
    
    open func reloadData() {
        
        self.tableView.reloadData()
        
    }
    
    // MARK: - Selectors
    
    @objc func didTapBackground(sender: AnyObject?) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        
        guard let kbSizeValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue else { return }
        guard let kbDurationNumber = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber else { return }
        animateToKeyboardHeight(kbHeight: kbSizeValue.cgRectValue.height, duration: kbDurationNumber.doubleValue)
        
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        
        guard let kbDurationNumber = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber else { return }
        animateToKeyboardHeight(kbHeight: 0, duration: kbDurationNumber.doubleValue)
        
    }
    
    func animateToKeyboardHeight(kbHeight: CGFloat, duration: Double) {
        
        tableView.contentInset = UIEdgeInsets(top: tableView.contentInset.top, left: 0, bottom: kbHeight, right: 0)
        tableView.scrollIndicatorInsets = UIEdgeInsets(top: tableView.contentInset.top, left: 0, bottom: kbHeight, right: 0)
        
    }
    
}

extension LFSearchViewController: UIGestureRecognizerDelegate {
    
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if let isDescendant = touch.view?.isDescendant(of: self.tableView), isDescendant {
            return false
        }
        
        return true
        
    }
    
}

extension LFSearchViewController: UITableViewDelegate {
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        self.delegate?.searchView(self, didSelectResultAt: indexPath.row)
        self.tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return self.delegate?.searchView(self, trailingSwipeActionsConfigurationForRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return self.delegate?.searchView(self, tableView: tableView, heightForRowAt: indexPath) ?? 0
        
    }
    
}

extension LFSearchViewController: UITableViewDataSource {
    
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return self.dataSource?.searchView(self, tableView: tableView, numberOfRowsInSection: section) ?? 0
        
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        return self.dataSource?.searchView(self,tableView: tableView, cellForRowAt: indexPath) ?? UITableViewCell()
        
    }
    
    public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        return self.dataSource?.searchView(self, tableView: tableView, canEditRowAt: indexPath) ?? false
        
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        self.dataSource?.searchView(self, tableView: tableView, commit: editingStyle, forRowAt: indexPath)
        
    }
    
}

extension LFSearchViewController: UISearchBarDelegate {
    
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        
        self.delegate?.searchView(self, didTextChangeTo: searchBar.text!, textLength: searchBar.text!.count)
        
    }
    
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        
        self.delegate?.searchView(self, didSearchForText: searchBar.text!)
        
    }
    
}

extension LFSearchViewController: WrapperDataSource {
    
    func statusBar() -> UIStatusBarStyle {
        return self.dataSource?.statusBarStyle() ?? .default
    }
    
}

private protocol WrapperDataSource {
    
    func statusBar() -> UIStatusBarStyle
    
}

private class WrapperNavigationController: UINavigationController {
    
    open var dataSource: WrapperDataSource?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return self.dataSource?.statusBar() ?? .default
    }
    
}
