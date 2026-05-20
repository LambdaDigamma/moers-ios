//
//  TimetableSearchViewController.swift
//
//
//  Created by Lennart Fischer on 19.05.26.
//

import Combine
import SwiftUI
import UIKit

public class TimetableSearchViewController: UIViewController {

    private let viewModel: TimetableViewModel
    private let detailViewControllerFactory: (Event.ID) -> UIViewController
    private let searchController: UISearchController
    private let hostingController: UIHostingController<TimetableSearchResultsView>

    private var cancellables = Set<AnyCancellable>()
    private var hasFocusedSearch = false
    private var hasCancelledSearch = false
    private var isSelectingSearchResult = false

    public init(
        viewModel: TimetableViewModel,
        detailViewControllerFactory: @escaping (Event.ID) -> UIViewController
    ) {
        self.viewModel = viewModel
        self.detailViewControllerFactory = detailViewControllerFactory
        self.searchController = UISearchController(searchResultsController: nil)
        self.hostingController = UIHostingController(
            rootView: TimetableSearchResultsView(
                query: viewModel.searchText,
                sections: viewModel.searchSections,
                state: viewModel.searchState
            )
        )

        super.init(nibName: nil, bundle: nil)

        hostingController.rootView = makeResultsView(
            query: viewModel.searchText,
            sections: viewModel.searchSections,
            state: viewModel.searchState
        )
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        setupSearchController()
        embedResultsView()
        bindViewModel()

        viewModel.setSearchActive(true)
    }

    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        configurePresentationDelegate()
        if navigationController?.topViewController === self {
            isSelectingSearchResult = false
        }
        focusSearchIfNeeded()
    }

    public override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)

        if isBeingDismissed || navigationController?.isBeingDismissed == true {
            cancelSearchIfNeeded()
        }
    }

    private func setupUI() {
        title = EventPackageStrings.searchEvents
        view.backgroundColor = .systemBackground
        navigationItem.largeTitleDisplayMode = .never
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelButtonTapped)
        )
    }

    private func setupSearchController() {
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        searchController.searchBar.delegate = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchBar.placeholder = EventPackageStrings.searchEvents
        searchController.searchBar.text = viewModel.searchText

        navigationItem.searchController = searchController
        navigationItem.preferredSearchBarPlacement = .stacked
        navigationItem.hidesSearchBarWhenScrolling = false
        if #available(iOS 26.0, *) {
            navigationItem.searchBarPlacementAllowsToolbarIntegration = false
        }
        definesPresentationContext = true
    }

    private func embedResultsView() {
        addChild(hostingController)

        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        hostingController.view.backgroundColor = .clear
        view.addSubview(hostingController.view)

        NSLayoutConstraint.activate([
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        hostingController.didMove(toParent: self)
    }

    private func bindViewModel() {
        Publishers.CombineLatest3(
            viewModel.$searchText,
            viewModel.$searchSections,
            viewModel.$searchState
        )
            .receive(on: DispatchQueue.main)
            .sink { [weak self] query, sections, state in
                guard let self else { return }

                if searchController.searchBar.text != query {
                    searchController.searchBar.text = query
                }

                hostingController.rootView = makeResultsView(
                    query: query,
                    sections: sections,
                    state: state
                )
            }
            .store(in: &cancellables)
    }

    private func makeResultsView(
        query: String,
        sections: [EventListSection],
        state: TimetableSearchState
    ) -> TimetableSearchResultsView {
        TimetableSearchResultsView(
            query: query,
            sections: sections,
            state: state,
            onSelectEvent: { [weak self] eventID in
                self?.selectEvent(eventID)
            },
            onRetrySearch: { [weak self] in
                self?.viewModel.retrySearch()
            }
        )
    }

    func selectEvent(_ eventID: Event.ID) {
        isSelectingSearchResult = true

        guard let navigationController else {
            isSelectingSearchResult = false
            assertionFailure("Timetable search must be embedded in a navigation controller.")
            return
        }

        let detailViewController = detailViewControllerFactory(eventID)
        navigationController.pushViewController(detailViewController, animated: true)

        searchController.searchBar.resignFirstResponder()
        searchController.searchBar.searchTextField.resignFirstResponder()
        searchController.isActive = false
    }

    private func focusSearchIfNeeded() {
        guard !hasFocusedSearch else { return }

        hasFocusedSearch = true
        viewModel.setSearchActive(true)

        DispatchQueue.main.async { [weak self] in
            self?.activateSearchField()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) { [weak self] in
            self?.activateSearchField()
        }
    }

    private func activateSearchField() {
        guard navigationController?.topViewController === self else { return }

        searchController.isActive = true
        searchController.searchBar.searchTextField.becomeFirstResponder()
    }

    private func configurePresentationDelegate() {
        presentationController?.delegate = self
        navigationController?.presentationController?.delegate = self
    }

    private func cancelAndDismiss() {
        cancelSearchIfNeeded()
        dismiss(animated: true)
    }

    private func cancelSearchIfNeeded() {
        guard !hasCancelledSearch else { return }

        hasCancelledSearch = true
        viewModel.cancelSearch()
    }

    @objc private func cancelButtonTapped() {
        cancelAndDismiss()
    }

}

extension TimetableSearchViewController: UISearchResultsUpdating {

    public func updateSearchResults(for searchController: UISearchController) {
        guard !isSelectingSearchResult else { return }

        viewModel.updateSearchText(searchController.searchBar.text ?? "")
    }

}

extension TimetableSearchViewController: UISearchControllerDelegate {

    public func willPresentSearchController(_ searchController: UISearchController) {
        viewModel.setSearchActive(true)
    }

    public func didPresentSearchController(_ searchController: UISearchController) {
        viewModel.setSearchActive(true)
    }

}

extension TimetableSearchViewController: UISearchBarDelegate {

    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        cancelAndDismiss()
    }

}

extension TimetableSearchViewController: UIAdaptivePresentationControllerDelegate {

    public func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        cancelSearchIfNeeded()
    }

}
