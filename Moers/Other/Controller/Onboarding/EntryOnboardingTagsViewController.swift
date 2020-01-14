//
//  EntryOnboardingTagsViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 16.10.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import TagListView
import Alertift
import Fuse
import MMAPI
import MMUI

class EntryOnboardingTagsViewController: UIViewController {

    lazy var scrollView = { ViewFactory.scrollView() }()
    lazy var contentView = { ViewFactory.blankView() }()
    lazy var progressView = { ViewFactory.onboardingProgressView() }()
    lazy var tagsHeaderLabel = { ViewFactory.label() }()
    lazy var tagsListView = { ViewFactory.tagListView() }()
    lazy var infoLabel = { ViewFactory.label() }()
    
    lazy var searchController = { LFSearchViewController() }()
    
    private var selectedTags: [String] = [] { didSet { updateNextButton() } }
    private var tags: [String] = []
    private var filteredTags: [NSAttributedString] = []
    private let fuse = Fuse(location: 0, distance: 100, threshold: 0.45, maxPatternLength: 32, isCaseSensitive: false)
    
    private var cellTextColor = UIColor.black
    private var cellBackgroundColor = UIColor.white
    
    private var entryManager: EntryManagerProtocol
    
    init(entryManager: EntryManagerProtocol) {
        self.entryManager = entryManager
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.setupConstraints()
        self.setupTheming()
        self.setupAddTag()
        self.getTags()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.checkData()
        
        self.progressView.progress = 0.6
        
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        
        self.title = String.localized("EntryOnboardingTagsViewControllerTitle")
        
        self.view.addSubview(scrollView)
        self.scrollView.addSubview(contentView)
        self.contentView.addSubview(progressView)
        self.contentView.addSubview(tagsHeaderLabel)
        self.contentView.addSubview(tagsListView)
        self.contentView.addSubview(infoLabel)
        
        self.progressView.currentStep = String.localized("EntryOnboardingTagsViewControllerCurrentStep")
        self.progressView.progress = 0.4
        
        self.tagsHeaderLabel.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.semibold)
        self.tagsHeaderLabel.text = String.localized("EntryOnboardingTagsViewControllerTags")
        
        self.infoLabel.font = UIFont.systemFont(ofSize: 12)
        self.infoLabel.numberOfLines = 0
        self.infoLabel.text = String.localized("EntryOnboardingTagsViewControllerInfo")
        
        self.searchController.delegate = self
        self.searchController.dataSource = self
        self.searchController.searchBar.textField?.returnKeyType = .next
        self.searchController.searchBarPlaceHolder = String.localized("EntryOnboardingTagsViewControllerSearchBarPlaceholder")
        
        let item = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(close))
        self.searchController.navigationItem.rightBarButtonItem = item
        
        self.updateNextButton()
        
    }
    
    private func setupConstraints() {
        
        let constraints = [scrollView.topAnchor.constraint(equalTo: self.safeTopAnchor, constant: 0),
                           scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
                           scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
                           scrollView.bottomAnchor.constraint(equalTo: self.safeBottomAnchor, constant: 0),
                           contentView.leftAnchor.constraint(equalTo: self.scrollView.leftAnchor),
                           contentView.rightAnchor.constraint(equalTo: self.scrollView.rightAnchor),
                           contentView.topAnchor.constraint(equalTo: self.scrollView.topAnchor),
                           contentView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor),
                           contentView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
                           progressView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 20),
                           progressView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16),
                           progressView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16),
                           tagsHeaderLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 20),
                           tagsHeaderLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16),
                           tagsHeaderLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16),
                           tagsListView.topAnchor.constraint(equalTo: tagsHeaderLabel.bottomAnchor, constant: 20),
                           tagsListView.leftAnchor.constraint(equalTo: contentView.leftAnchor, constant: 16),
                           tagsListView.rightAnchor.constraint(equalTo: contentView.rightAnchor, constant: -16),
                           infoLabel.topAnchor.constraint(equalTo: tagsListView.bottomAnchor, constant: 20),
                           infoLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16),
                           infoLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16),
                           infoLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -50),]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        MMUIConfig.themeManager?.manage(theme: \ApplicationTheme.self, for: self)
        
    }
    
    @objc private func close() {
        
        self.searchController.dismiss(animated: true)
        
    }
    
    // MARK: - Helper
    
    private func setupAddTag() {
        
        self.tagsListView.delegate = self
        self.tagsListView.enableRemoveButton = true
        
        let addTagView = tagsListView.addTag(String.localized("EntryOnboardingTagsViewControllerAddTag"))

        addTagView.tagBackgroundColor = UIColor.gray
        addTagView.textColor = UIColor.white
        addTagView.enableRemoveButton = false
        
        addTagView.onTap = showSearchController(_:)
        
    }
    
    private func getTags() {
        
        guard let tabBarController = self.tabBarController as? TabBarController else { return }
        
        let locations = tabBarController.map.mainViewController?.locations ?? []
        
        // TODO: Improve Tag Fetching
        self.tags = Array(Set(locations.map { $0.tags }.reduce([], +))).sorted()
        self.tags.removeAll(where: { $0.isEmptyOrWhitespace })
        
    }
    
    private func showSearchController(_ tagView: TagView) {
        
        self.filteredTags = tags.map { NSAttributedString(string: $0) }
        
        self.searchController.show(in: self)
        self.searchController.reloadData()
        
    }
    
    private func searchTags(with searchTerm: String) -> [NSAttributedString] {
        
        let results = fuse.search(searchTerm, in: tags)
        
        let boldAttrs = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 15)]
        
        let filteredTags: [NSAttributedString] = results.sorted(by: { $0.score < $1.score }).map { result in
            
            let tag = tags[result.index]
            
            let attributedString = NSMutableAttributedString(string: tag)
            
            result.ranges.map(Range.init).map(NSRange.init).forEach {
                attributedString.addAttributes(boldAttrs, range: $0)
            }
            
            return attributedString
            
        }
        
        return filteredTags
        
    }
    
    private func addTag(_ tag: String) {
        
        if !selectedTags.contains(tag) {
            
            let index = self.tagsListView.tagViews.count - 1
            
            self.selectedTags.append(tag)
            
            self.searchController.dismiss(animated: true) {
                self.tagsListView.insertTag(tag, at: index)
            }
            
        }
        
    }
    
    private func checkData() {
        
        if !entryManager.entryTags.isEmpty {
            
            self.selectedTags = []
            self.tagsListView.removeAllTags()
            self.setupAddTag()
            
            entryManager.entryTags.forEach { tag in
                
                if !selectedTags.contains(tag) {
                    
                    let index = self.tagsListView.tagViews.count - 1
                    
                    self.selectedTags.append(tag)
                    self.tagsListView.insertTag(tag, at: index)
                    
                }
                
            }
            
        }
        
    }
    
    private func updateNextButton() {
        
        if selectedTags.count != 0 {
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: String.localized("EntryOnboardingTagsViewControllerNext"),
                                                                     style: .plain,
                                                                     target: self,
                                                                     action: #selector(self.continueOnboarding))
            
        } else {
            
            self.navigationItem.rightBarButtonItem = nil
            
        }
        
    }
    
    @objc private func continueOnboarding() {
        
        entryManager.entryTags = selectedTags
        
        let viewController = EntryOnboardingOpeningHoursViewController(entryManager: entryManager)
        
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
}

extension EntryOnboardingTagsViewController: TagListViewDelegate {
    
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        
    }
    
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        
        sender.removeTagView(tagView)
        
        self.selectedTags.removeAll(where: { $0 == title })
        
    }
    
}

extension EntryOnboardingTagsViewController: LFSearchViewDataSource, LFSearchViewDelegate {
    
    func searchView(_ searchView: LFSearchViewController, tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let tag = self.searchController.searchBar?.textField?.text, tag.isNotEmptyOrWhitespace, !tags.contains(tag) {
            return filteredTags.count + 1
        } else {
            return filteredTags.count
        }
        
    }
    
    func searchView(_ searchView: LFSearchViewController, didTextChangeTo text: String, textLength: Int) {
        
        let text = text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if text.isEmpty {
            self.filteredTags = tags.map { NSAttributedString(string: $0) }
        } else {
            self.filteredTags = searchTags(with: text)
        }
        
        searchView.reloadData()
        
    }
    
    func searchView(_ searchView: LFSearchViewController, didSelectResultAt index: Int) {
        
        if index != filteredTags.count {
            
            let tag = filteredTags[index].string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
            self.addTag(tag)
            
        } else {
            
            guard let tag = searchView.searchBar.textField?.text?.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines) else { return }
            self.addTag(tag)
            
        }
        
        self.searchController.searchBar?.textField?.text = ""
        
    }
    
    func searchView(_ searchView: LFSearchViewController, didSearchForText text: String) {
        
        let tag = text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        self.addTag(tag)
        
        self.searchController.searchBar?.textField?.text = ""
        
    }
    
    func searchView(_ searchView: LFSearchViewController, tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: searchView.cellIdentifier)!
        
        if indexPath.row == filteredTags.count {
            
            if let tag = self.searchController.searchBar?.textField?.text, tag.isNotEmptyOrWhitespace, !tags.contains(tag) {
                
                cell.textLabel?.text = String(format: String.localized("EntryOnboardingTagsViewControllerAddTagCell"), tag)
                
            }
            
        } else {
            
            cell.textLabel?.attributedText = self.filteredTags[indexPath.row]
            
        }
        
        cell.textLabel?.textColor = self.cellTextColor
        cell.contentView.backgroundColor = self.cellBackgroundColor
        cell.selectionStyle = .none
        
        return cell
        
    }
    
}

extension EntryOnboardingTagsViewController: Themeable {
    
    typealias Theme = ApplicationTheme
    
    func apply(theme: ApplicationTheme) {
        
        self.view.backgroundColor = theme.backgroundColor
        self.progressView.accentColor = theme.accentColor
        self.progressView.decentColor = theme.decentColor
        self.progressView.textColor = theme.color
        self.infoLabel.textColor = theme.color
        self.tagsHeaderLabel.textColor = theme.decentColor
        self.tagsListView.tagBackgroundColor = theme.accentColor
        self.tagsListView.textColor = theme.backgroundColor
        self.tagsListView.removeIconLineColor = theme.backgroundColor
        self.searchController.searchBarBackgroundColor = theme.navigationBarColor
        self.searchController.keyboardAppearance = theme.statusBarStyle == .lightContent ? .dark : .light
        self.searchController.searchBar.textField?.textColor = theme.color
        self.searchController.tableView.separatorColor = .clear
        self.searchController.navigationItem.rightBarButtonItem?.tintColor = theme.accentColor
        self.cellTextColor = theme.color
        self.cellBackgroundColor = theme.backgroundColor
        self.searchController.tableView.backgroundColor = theme.backgroundColor
        self.searchController.separatorColor = theme.separatorColor
        self.searchController.view.backgroundColor = theme.backgroundColor
        self.searchController.navigationBarClosure = { bar in
            
            bar.barTintColor = theme.navigationBarColor
            bar.tintColor = theme.accentColor
            
        }
        
    }
    
}
