//
//  EntryOnboardingOverviewViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 17.10.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import TextFieldEffects
import MapKit
import Alertift
import MMAPI
import MMUI
import TagListView
import Fuse

enum EntryOverviewType: Equatable {
    case summary
    case edit(entry: Entry)
}

class EntryOnboardingOverviewViewController: UIViewController {

    lazy var searchController = { LFSearchViewController() }()
    lazy var scrollView = { ViewFactory.scrollView() }()
    lazy var contentView = { ViewFactory.blankView() }()
    lazy var generalHeaderLabel = { ViewFactory.label() }()
    lazy var nameTextField = { ViewFactory.textFieldFormView() }()
    lazy var tagsHeaderLabel = { ViewFactory.label() }()
    lazy var tagsListView = { ViewFactory.tagListView() }()
    lazy var addressHeaderLabel = { ViewFactory.label() }()
    lazy var streetTextField = { ViewFactory.textFieldFormView() }()
    lazy var houseNrTextField = { ViewFactory.textFieldFormView() }()
    lazy var postcodeTextField = { ViewFactory.textFieldFormView() }()
    lazy var placeTextField = { ViewFactory.textFieldFormView() }()
    lazy var mapView = { ViewFactory.map() }()
    lazy var promptLabel = { ViewFactory.label() }()
    lazy var contactHeaderLabel = { ViewFactory.label() }()
    lazy var websiteTextField = { ViewFactory.textFieldFormView() }()
    lazy var phoneTextField = { ViewFactory.textFieldFormView() }()
    lazy var openingHoursHeaderLabel = { ViewFactory.label() }()
    lazy var openingHoursStackView = { ViewFactory.stackView() }()
    lazy var mondayOHTextField = { ViewFactory.textFieldFormView() }()
    lazy var tuesdayOHTextField = { ViewFactory.textFieldFormView() }()
    lazy var wednesdayOHTextField = { ViewFactory.textFieldFormView() }()
    lazy var thursdayOHTextField = { ViewFactory.textFieldFormView() }()
    lazy var fridayOHTextField = { ViewFactory.textFieldFormView() }()
    lazy var saturdayOHTextField = { ViewFactory.textFieldFormView() }()
    lazy var sundayOHTextField = { ViewFactory.textFieldFormView() }()
    lazy var otherOHTextField = { ViewFactory.textFieldFormView() }()
    lazy var saveButton = { ViewFactory.button() }()
    lazy var noticeView: OnboardingOverviewNotice = {
        let notice = OnboardingOverviewNotice()
        notice.translatesAutoresizingMaskIntoConstraints = false
        return notice
    }()
    
    var form = Form()
    
    public var overviewType = EntryOverviewType.summary
    
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
        self.setupOpeningHours()
        self.setupTheming()
        self.setupDataForOverviewType()
        
    }
    
    // MARK: - UI
    
    private func setupUI() {
        
        if overviewType == .summary {
            self.title = String.localized("EntryOnboardingOverviewSummaryTitle")
        } else {
            self.title = String.localized("EntryOnboardingOverviewEditTitle")
        }
        
        self.view.addSubview(scrollView)
        self.scrollView.addSubview(contentView)
        self.contentView.addSubview(noticeView)
        self.contentView.addSubview(generalHeaderLabel)
        self.contentView.addSubview(nameTextField)
        self.contentView.addSubview(tagsHeaderLabel)
        self.contentView.addSubview(tagsListView)
        self.contentView.addSubview(addressHeaderLabel)
        self.contentView.addSubview(streetTextField)
        self.contentView.addSubview(houseNrTextField)
        self.contentView.addSubview(postcodeTextField)
        self.contentView.addSubview(placeTextField)
        self.contentView.addSubview(mapView)
        self.contentView.addSubview(contactHeaderLabel)
        self.contentView.addSubview(websiteTextField)
        self.contentView.addSubview(phoneTextField)
        self.contentView.addSubview(openingHoursHeaderLabel)
        self.contentView.addSubview(openingHoursStackView)
        self.contentView.addSubview(saveButton)
        
        self.form.registerView(for: "name", view: nameTextField)
        self.form.registerView(for: "street", view: streetTextField)
        self.form.registerView(for: "house_number", view: houseNrTextField)
        self.form.registerView(for: "postcode", view: postcodeTextField)
        self.form.registerView(for: "place", view: placeTextField)
        self.form.registerView(for: "url", view: websiteTextField)
        self.form.registerView(for: "phone", view: phoneTextField)
        self.form.registerView(for: "monday", view: mondayOHTextField)
        self.form.registerView(for: "tuesday", view: tuesdayOHTextField)
        self.form.registerView(for: "wednesday", view: wednesdayOHTextField)
        self.form.registerView(for: "thursday", view: thursdayOHTextField)
        self.form.registerView(for: "friday", view: fridayOHTextField)
        self.form.registerView(for: "saturday", view: saturdayOHTextField)
        self.form.registerView(for: "sunday", view: sundayOHTextField)
        self.form.registerView(for: "other", view: otherOHTextField)
        
        [
            nameTextField,
            streetTextField,
            houseNrTextField,
            postcodeTextField,
            placeTextField,
            websiteTextField,
            phoneTextField,
            mondayOHTextField,
            tuesdayOHTextField,
            wednesdayOHTextField,
            thursdayOHTextField,
            fridayOHTextField,
            saturdayOHTextField,
            sundayOHTextField,
            otherOHTextField
        ].forEach { $0.textFieldDelegate = self }
        
        self.generalHeaderLabel.text = String.localized("EntryOnboardingOverviewGeneralHeader").uppercased()
        self.nameTextField.placeholder = String.localized("EntryOnboardingOverviewName")
        self.tagsHeaderLabel.text = String.localized("EntryOnboardingOverviewTagsHeader").uppercased()
        self.addressHeaderLabel.text = String.localized("EntryOnboardingOverviewAddressHeader").uppercased()
        self.streetTextField.placeholder = String.localized("EntryOnboardingOverviewStreet")
        self.houseNrTextField.placeholder = String.localized("EntryOnboardingOverviewHouseNr")
        self.postcodeTextField.placeholder = String.localized("EntryOnboardingOverviewPostcode")
        self.placeTextField.placeholder = String.localized("EntryOnboardingOverviewPlace")
        self.contactHeaderLabel.text = String.localized("EntryOnboardingOverviewContact").uppercased()
        self.websiteTextField.placeholder = String.localized("EntryOnboardingOverviewWebsite")
        self.phoneTextField.placeholder = String.localized("EntryOnboardingOverviewPhone")
        self.openingHoursHeaderLabel.text = String.localized("EntryOnboardingOverviewOpeningHoursHeader").uppercased()
        self.mondayOHTextField.placeholder = String.localized("EntryOnboardingOverviewOpeningHoursMonday")
        self.tuesdayOHTextField.placeholder = String.localized("EntryOnboardingOverviewOpeningHoursTuesday")
        self.wednesdayOHTextField.placeholder = String.localized("EntryOnboardingOverviewOpeningHoursWednesday")
        self.thursdayOHTextField.placeholder = String.localized("EntryOnboardingOverviewOpeningHoursThursday")
        self.fridayOHTextField.placeholder = String.localized("EntryOnboardingOverviewOpeningHoursFriday")
        self.saturdayOHTextField.placeholder = String.localized("EntryOnboardingOverviewOpeningHoursSaturday")
        self.sundayOHTextField.placeholder = String.localized("EntryOnboardingOverviewOpeningHoursSunday")
        self.otherOHTextField.placeholder = String.localized("EntryOnboardingOverviewOpeningHoursOther")
        
        self.websiteTextField.textField.autocapitalizationType = .none
        
        if overviewType == EntryOverviewType.summary {
            self.saveButton.setTitle(String.localized("EntryOnboardingOverviewActionStore"), for: .normal)
            self.noticeView.notice = String.localized("EntryOnboardingOverviewStoreNotice")
        } else {
            self.saveButton.setTitle(String.localized("EntryOnboardingOverviewActionUpdate"), for: .normal)
            self.noticeView.notice = String.localized("EntryOnboardingOverviewUpdateNotice")
        }
        
        self.tagsListView.enableRemoveButton = false
        
        [
            generalHeaderLabel,
            tagsHeaderLabel,
            addressHeaderLabel,
            contactHeaderLabel,
            openingHoursHeaderLabel,
        ].forEach { $0.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.semibold) }
        
        
        self.mapView.isScrollEnabled = false
        self.mapView.isZoomEnabled = false
        self.mapView.isPitchEnabled = false
        self.mapView.isRotateEnabled = false
        self.mapView.showsCompass = false
        
        self.saveButton.layer.cornerRadius = 8
        self.saveButton.clipsToBounds = true
        self.saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.bold)
        self.saveButton.addTarget(self, action: #selector(alertConfirm), for: .touchUpInside)
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
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
                           noticeView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 0),
                           noticeView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
                           noticeView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
                           generalHeaderLabel.topAnchor.constraint(equalTo: self.noticeView.bottomAnchor, constant: 16),
                           generalHeaderLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16),
                           generalHeaderLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16),
                           nameTextField.topAnchor.constraint(equalTo: self.generalHeaderLabel.bottomAnchor, constant: 0),
                           nameTextField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
                           nameTextField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
                           tagsHeaderLabel.topAnchor.constraint(equalTo: self.nameTextField.bottomAnchor, constant: 16),
                           tagsHeaderLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
                           tagsHeaderLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
                           tagsListView.topAnchor.constraint(equalTo: self.tagsHeaderLabel.bottomAnchor, constant: 8),
                           tagsListView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
                           tagsListView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
                           addressHeaderLabel.topAnchor.constraint(equalTo: self.tagsListView.bottomAnchor, constant: 16),
                           addressHeaderLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
                           addressHeaderLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
                           streetTextField.topAnchor.constraint(equalTo: self.addressHeaderLabel.bottomAnchor, constant: 0),
                           streetTextField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
                           streetTextField.trailingAnchor.constraint(equalTo: self.houseNrTextField.leadingAnchor, constant: -8),
                           houseNrTextField.topAnchor.constraint(equalTo: self.streetTextField.topAnchor),
                           houseNrTextField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
                           houseNrTextField.widthAnchor.constraint(equalToConstant: 55),
                           postcodeTextField.topAnchor.constraint(equalTo: self.houseNrTextField.bottomAnchor, constant: 8),
                           postcodeTextField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
                           postcodeTextField.trailingAnchor.constraint(equalTo: self.placeTextField.leadingAnchor, constant: -8),
                           postcodeTextField.widthAnchor.constraint(equalToConstant: 80),
                           placeTextField.topAnchor.constraint(equalTo: self.houseNrTextField.bottomAnchor, constant: 8),
                           placeTextField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
                           mapView.topAnchor.constraint(equalTo: self.placeTextField.bottomAnchor, constant: 20),
                           mapView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
                           mapView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
                           mapView.heightAnchor.constraint(equalToConstant: 180),
                           contactHeaderLabel.topAnchor.constraint(equalTo: self.mapView.bottomAnchor, constant: 20),
                           contactHeaderLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
                           contactHeaderLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
                           websiteTextField.topAnchor.constraint(equalTo: self.contactHeaderLabel.bottomAnchor, constant: 0),
                           websiteTextField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
                           websiteTextField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
                           phoneTextField.topAnchor.constraint(equalTo: self.websiteTextField.bottomAnchor, constant: 16),
                           phoneTextField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
                           phoneTextField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
                           openingHoursHeaderLabel.topAnchor.constraint(equalTo: phoneTextField.bottomAnchor, constant: 16),
                           openingHoursHeaderLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
                           openingHoursHeaderLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
                           openingHoursStackView.topAnchor.constraint(equalTo: openingHoursHeaderLabel.bottomAnchor, constant: 0),
                           openingHoursStackView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
                           openingHoursStackView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
                           saveButton.topAnchor.constraint(equalTo: self.openingHoursStackView.bottomAnchor, constant: 16),
                           saveButton.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
                           saveButton.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
                           saveButton.heightAnchor.constraint(equalToConstant: 45),
                           saveButton.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -50)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        MMUIConfig.themeManager?.manage(theme: \Theme.self, for: self)
        
    }
    
    private func setupOpeningHours() {
        
        let columnStackView: ((TextFieldFormView, TextFieldFormView) -> UIStackView) = { textField1, textField2 in
            
            let stackView = UIStackView()
            
            stackView.alignment = .fill
            stackView.axis = .horizontal
            stackView.distribution = .fillEqually
            stackView.spacing = 8
            
            stackView.addArrangedSubview(textField1)
            stackView.addArrangedSubview(textField2)
            
            return stackView
            
        }
        
        openingHoursStackView.alignment = .fill
        openingHoursStackView.axis = .vertical
        openingHoursStackView.distribution = .fillEqually
        openingHoursStackView.spacing = 8
        
        openingHoursStackView.addArrangedSubview(columnStackView(mondayOHTextField, tuesdayOHTextField))
        openingHoursStackView.addArrangedSubview(columnStackView(wednesdayOHTextField, thursdayOHTextField))
        openingHoursStackView.addArrangedSubview(columnStackView(fridayOHTextField, saturdayOHTextField))
        openingHoursStackView.addArrangedSubview(columnStackView(sundayOHTextField, otherOHTextField))
        
    }
    
    // MARK: - Data Handling
    
    private func setupDataForOverviewType() {
        
        switch overviewType {
        case .summary:
            
            self.setupSummary()
            
        case .edit(let entry):
            
            self.setupEdit(with: entry)
            
        }
        
    }
    
    // MARK: - Actions
    
    @objc private func adjustForKeyboard(notification: Notification) {
        
        guard let userInfo = notification.userInfo else { return }
        
        let keyboardScreenEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            scrollView.contentInset = UIEdgeInsets.zero
        } else {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        
        scrollView.scrollIndicatorInsets = scrollView.contentInset
        
    }
    
    @objc private func save() {
        
        switch overviewType {
        case .summary:
            self.storeEntry()
        case .edit(let entry):
            self.updateEntry(entry)
        }
        
        // TODO: Update Entry Model from Text Fields
        // TODO: Diff between Adding and Editing
        // TODO: Adjust Alerts
        // TODO: Update the Model in other VCs
        
    }
    
    // MARK: - Filling Summary Data
    
    private func setupSummary() {
        
        self.nameTextField.text = entryManager.entryName
        self.phoneTextField.text = entryManager.entryPhone
        self.websiteTextField.text = entryManager.entryWebsite
        self.streetTextField.text = entryManager.entryStreet
        self.houseNrTextField.text = entryManager.entryHouseNumber
        self.postcodeTextField.text = entryManager.entryPostcode
        self.placeTextField.text = entryManager.entryPlace
        self.mondayOHTextField.text = entryManager.entryMondayOH
        self.tuesdayOHTextField.text = entryManager.entryTuesdayOH
        self.wednesdayOHTextField.text = entryManager.entryWednesdayOH
        self.thursdayOHTextField.text = entryManager.entryThursdayOH
        self.fridayOHTextField.text = entryManager.entryFridayOH
        self.saturdayOHTextField.text = entryManager.entrySaturdayOH
        self.sundayOHTextField.text = entryManager.entrySundayOH
        self.otherOHTextField.text = entryManager.entryOtherOH
        
        // disableTextFields([nameTextField, phoneTextField, websiteTextField, streetTextField, houseNrTextField, postcodeTextField, placeTextField, mondayOHTextField, tuesdayOHTextField, wednesdayOHTextField, thursdayOHTextField, fridayOHTextField, saturdayOHTextField, sundayOHTextField, otherOHTextField])
        
        let coordinate = CLLocationCoordinate2D(latitude: entryManager.entryLat ?? 0, longitude: entryManager.entryLng ?? 0)
        
        self.setupMap(with: coordinate)
        self.setupTags(with: entryManager.entryTags)
        
    }
    
    // MARK: - Filling Editing Data
    
    private func setupEdit(with entry: Entry) {
        
        self.nameTextField.text = entry.name
        self.phoneTextField.text = entry.phone
        self.websiteTextField.text = entry.url
        self.streetTextField.text = entry.street
        self.houseNrTextField.text = entry.houseNumber
        self.postcodeTextField.text = entry.postcode
        self.placeTextField.text = entry.place
        self.mondayOHTextField.text = entry.monday
        self.tuesdayOHTextField.text = entry.tuesday
        self.wednesdayOHTextField.text = entry.wednesday
        self.thursdayOHTextField.text = entry.thursday
        self.fridayOHTextField.text = entry.friday
        self.saturdayOHTextField.text = entry.saturday
        self.sundayOHTextField.text = entry.sunday
        self.otherOHTextField.text = entry.other
        
        disableTextFields([streetTextField, houseNrTextField, postcodeTextField, placeTextField])
        
        self.setupMap(with: entry.coordinate)
        self.setupTags(with: entry.tags, enableAddTag: true)
        self.selectedTags = entry.tags
        self.loadAllExistingTags()
        
        self.searchController.delegate = self
        self.searchController.dataSource = self
        self.searchController.searchBarPlaceHolder = String.localized("EntryOnboardingOverviewSearchBarAddTag")
        
        let item = UIBarButtonItem(barButtonSystemItem: .stop, target: self, action: #selector(close))
        self.searchController.navigationItem.rightBarButtonItem = item
        
        print(allLoadedTags)
        
    }
    
    private func setupMap(with coordinate: CLLocationCoordinate2D) {
        
        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.0025, longitudeDelta: 0.0025))
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = coordinate
        
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.addAnnotation(annotation)
        self.mapView.setCenter(coordinate, animated: false)
        self.mapView.setRegion(region, animated: false)
        self.mapView.alpha = 1
        
    }
    
    private func setupTags(with tags: [String], enableAddTag: Bool = false) {
        
        self.tagsListView.removeAllTags()
        
        tags.forEach { tag in
            
            let index = self.tagsListView.tagViews.count
            
            self.tagsListView.insertTag(tag, at: index)
            
        }
        
        if enableAddTag {
            
            self.tagsListView.delegate = self
            self.tagsListView.enableRemoveButton = true
            
            let addTagView = tagsListView.addTag(String.localized("EntryOnboardingOverviewAddTag"))

            addTagView.tagBackgroundColor = UIColor.gray
            addTagView.textColor = UIColor.white
            addTagView.enableRemoveButton = false
            
            addTagView.onTap = showSearch

            
        }
        
    }
    
    private func disableTextFields(_ textFields: [TextFieldFormView]) {
        textFields.forEach { $0.isEnabled = false }
    }
    
    // MARK: - Networking
    
    private func storeEntry() {
        
        let entry = Entry(id: -1,
                          name: entryManager.entryName ?? "",
                          tags: entryManager.entryTags,
                          street: entryManager.entryStreet ?? "",
                          houseNumber: entryManager.entryHouseNumber ?? "",
                          postcode: entryManager.entryPostcode ?? "",
                          place: entryManager.entryPlace ?? "",
                          url: entryManager.entryWebsite,
                          phone: entryManager.entryPhone,
                          monday: entryManager.entryMondayOH,
                          tuesday: entryManager.entryTuesdayOH,
                          wednesday: entryManager.entryWednesdayOH,
                          thursday: entryManager.entryThursdayOH,
                          friday: entryManager.entryFridayOH,
                          saturday: entryManager.entrySaturdayOH,
                          sunday: entryManager.entrySundayOH,
                          other: entryManager.entryOtherOH,
                          lat: entryManager.entryLat ?? 0,
                          lng: entryManager.entryLng ?? 0,
                          isValidated: true)
        
        entryManager.store(entry: entry) { (result) in
            
            switch result {
                
            case .success(let entry):
                
                DispatchQueue.main.async {
                    
                    self.alertSuccess()
                    self.entryManager.resetData()
                    
                    guard let tabBarController = self.tabBarController as? TabBarController else { return }
                    
                    tabBarController.mainViewController.addLocation(entry)
                    
                }
                
            case .failure(let error):
                
                print(error.localizedDescription)
                print((error as? DecodingError) ?? "")
                
                guard let error = error as? APIError else {
                    self.alertUnknownError()
                    return
                }
                
                switch error {
                case .notAuthorized:
                    self.alertNotAuthorized()
                case .unprocessableEntity(let errorBag):
                    
                    DispatchQueue.main.async {
                        self.alertErrorInForm(with: errorBag)
                        self.form.receivedError(errorBag: errorBag)
                    }
                    
                default:
                    break
                }
                
            }
            
        }
        
    }
    
    private func updateEntry(_ entry: Entry) {
        
        entry.name = nameTextField.text ?? ""
        entry.url = websiteTextField.text
        entry.phone = phoneTextField.text
        entry.monday = mondayOHTextField.text
        entry.tuesday = tuesdayOHTextField.text
        entry.wednesday = wednesdayOHTextField.text
        entry.thursday = thursdayOHTextField.text
        entry.friday = fridayOHTextField.text
        entry.saturday = saturdayOHTextField.text
        entry.sunday = sundayOHTextField.text
        entry.other = otherOHTextField.text
        entry.tags = selectedTags
        
        entryManager.update(entry: entry) { (result) in
            
            DispatchQueue.main.async {
            
                switch result {
                    
                case .success(_):
                    
                    self.alertSuccess()
                    
                    guard let tabBarController = self.tabBarController as? TabBarController else { return }
                    
                    tabBarController.mainViewController.loadData()
                    
                    // TODO: Update Entry in Map
                    
                case .failure(let error):
                    
                    print(error.localizedDescription)
                    print((error as? DecodingError) ?? "")
                    
                    guard let error = error as? APIError else {
                        self.alertUnknownError()
                        return
                    }
                    
                    switch error {
                    case .notAuthorized:
                        self.alertNotAuthorized()
                    case .unprocessableEntity(let errorBag):
                        self.alertErrorInForm(with: errorBag)
                    default:
                        break
                    }
                    
                }
                
            }
            
        }
        
    }
    
    // MARK: - Alerts
    
    @objc private func alertConfirm() {
        
        let message = overviewType == .summary ?
            String.localized("EntryOnboardingOverviewAlertConfirmStoreMessage") :
            String.localized("EntryOnboardingOverviewAlertConfirmUpdateMessage")
        
        
        Alertift
            .alert(title: String.localized("EntryOnboardingOverviewAlertConfirmTitle"),
                   message: message)
            .titleTextColor(nameTextField.textColor)
            .messageTextColor(nameTextField.textColor)
            .buttonTextColor(nameTextField.textColor)
            .backgroundColor(view.backgroundColor)
            .action(Alertift.Action.cancel(String.localized("EntryOnboardingOverviewAlertConfirmCancel")))
            .action(.default(String.localized("EntryOnboardingOverviewAlertConfirmYes")), isPreferred: true, handler: { (action, i, textFields) in
                
                self.save()
                
            })
            .show()
        
    }
    
    private func alertSuccess() {
        
        let title = overviewType == .summary ?
            String.localized("EntryOnboardingOverviewAlertSuccessTitleAdded") :
            String.localized("EntryOnboardingOverviewAlertSuccessTitleUpdated")
        
        Alertift
            .alert(title: title,
                   message: String.localized("EntryOnboardingOverviewAlertSuccessMessage"))
            .titleTextColor(nameTextField.textColor)
            .messageTextColor(nameTextField.textColor)
            .buttonTextColor(nameTextField.textColor)
            .backgroundColor(view.backgroundColor)
            .action(.default(String.localized("EntryOnboardingOverviewAlertSuccessOkay")),
                    handler: { (action, i, textFields) in
                
                if self.overviewType == .summary {
                    
                    guard let otherVC = self.navigationController?.children.first else { return }
                    
                    self.navigationController?.popToViewController(otherVC, animated: true)
                    
                } else {
                    
                    self.navigationController?.popViewController(animated: true)
                    
                }
                
            })
            .show()
        
    }
    
    private func alertUnknownError() {
        
        DispatchQueue.main.async {
            
            Alertift
                .alert(title: String.localized("EntryOnboardingOverviewAlertUnknownErrorTitle"),
                       message: String.localized("EntryOnboardingOverviewAlertUnknownErrorMessage"))
                .titleTextColor(self.nameTextField.textColor)
                .messageTextColor(self.nameTextField.textColor)
                .buttonTextColor(self.nameTextField.textColor)
                .backgroundColor(self.view.backgroundColor)
                .action(.default(String.localized("EntryOnboardingOverviewAlertUnknownErrorOkay")))
                .show()
            
        }
        
    }
    
    private func alertNotAuthorized() {
        
        Alertift
            .alert(title: String.localized("EntryOnboardingOverviewAlertNotAllowedTitle"),
                   message: String.localized("EntryOnboardingOverviewAlertNotAllowedMessage"))
            .titleTextColor(nameTextField.textColor)
            .messageTextColor(nameTextField.textColor)
            .buttonTextColor(nameTextField.textColor)
            .backgroundColor(view.backgroundColor)
            .action(.default(String.localized("EntryOnboardingOverviewAlertNotAllowedErrorOkay")),
                    handler: { (action, i, textFields) in
                
                guard let otherVC = self.navigationController?.children.first else { return }
                
                self.navigationController?.popToViewController(otherVC, animated: true)
                
            })
            .show()
        
    }
    
    private func alertErrorInForm(with errorBag: ErrorBag?) {
        
        DispatchQueue.main.async {
            
            Alertift
                .alert(title: String.localized("EntryOnboardingOverviewAlertFormErrorTitle"),
                       message: String.localized("EntryOnboardingOverviewAlertFormErrorMessage"))
                .titleTextColor(self.nameTextField.textColor)
                .messageTextColor(self.nameTextField.textColor)
                .buttonTextColor(self.nameTextField.textColor)
                .backgroundColor(self.view.backgroundColor)
                .action(.default(String.localized("EntryOnboardingOverviewAlertFormErrorOkay")))
                .show()
            
        }
        
    }
    
    // MARK: - Tags
    
    private var selectedTags: [String] = []
    private var allLoadedTags: [String] = []
    private var searchResultTags: [NSAttributedString] = []
    private let fuse = Fuse(location: 0,
                            distance: 100,
                            threshold: 0.45,
                            maxPatternLength: 32,
                            isCaseSensitive: false)
    
    private var cellTextColor = UIColor.black
    private var cellBackgroundColor = UIColor.white
    
    private func showSearch(_ tagView: TagView) {
            
        self.searchResultTags = allLoadedTags.map { NSAttributedString(string: $0) }

        self.searchController.show(in: self)
        self.searchController.reloadData()
        
    }
    
    private func loadAllExistingTags() {
        
        guard let tabBarController = self.tabBarController as? TabBarController else { return }
        
        let locations = tabBarController.mainViewController.locations
        
        // TODO: Improve Tag Fetching
        self.allLoadedTags = Array(Set(locations.map { $0.tags }.reduce([], +))).sorted()
        self.allLoadedTags.removeAll(where: { $0.isEmptyOrWhitespace })
        
    }
    
    private func addAndDisplayTagIfNotExisted(_ tag: String) {
        
        if !selectedTags.contains(tag) {
            
            let index = self.tagsListView.tagViews.count - 1
            
            self.selectedTags.append(tag)
            
            self.searchController.dismiss(animated: true) {
                self.tagsListView.insertTag(tag, at: index)
            }
            
        }
        
    }
    
    private func searchResults(for searchTerm: String) -> [NSAttributedString] {
        
        let results = fuse.search(searchTerm, in: allLoadedTags)
        
        let boldAttrs = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 17)]
        
        let filteredTags: [NSAttributedString] = results.sorted(by: { $0.score < $1.score }).map { result in
            
            let tag = allLoadedTags[result.index]
            
            let attributedString = NSMutableAttributedString(string: tag)
            
            result.ranges.map(Range.init).map(NSRange.init).forEach {
                attributedString.addAttributes(boldAttrs, range: $0)
            }
            
            return attributedString
            
        }
        
        return filteredTags
        
    }
    
    @objc private func close() {
        
        self.searchController.dismiss(animated: true)
        
    }
    
}

extension EntryOnboardingOverviewViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
}

extension EntryOnboardingOverviewViewController: Themeable {
    
    typealias Theme = ApplicationTheme
    
    func apply(theme: Theme) {
        
        self.view.backgroundColor = theme.backgroundColor
        self.generalHeaderLabel.textColor = theme.decentColor
        self.tagsHeaderLabel.textColor = theme.decentColor
        self.addressHeaderLabel.textColor = theme.decentColor
        self.contactHeaderLabel.textColor = theme.decentColor
        self.openingHoursHeaderLabel.textColor = theme.decentColor
        self.promptLabel.textColor = theme.color
        self.tagsListView.tagBackgroundColor = theme.accentColor
        self.tagsListView.textColor = theme.backgroundColor
        self.tagsListView.removeIconLineColor = theme.backgroundColor
        
        self.mapView.layer.cornerRadius = 10
        self.saveButton.setTitleColor(theme.backgroundColor, for: .normal)
        self.saveButton.setBackgroundColor(color: theme.accentColor, forState: .normal)
        self.saveButton.setBackgroundColor(color: theme.accentColor.darker(by: 10)!, forState: .selected)
        
        if #available(iOS 13.0, *) {
            
            navigationController?.navigationBar.barTintColor = theme.navigationBarColor
            navigationController?.navigationBar.tintColor = theme.accentColor
            navigationController?.navigationBar.prefersLargeTitles = true
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: theme.accentColor]
            navigationController?.navigationBar.largeTitleTextAttributes = [NSAttributedString.Key.foregroundColor: theme.accentColor]
            navigationController?.navigationBar.isTranslucent = true
            
            let appearance = UINavigationBarAppearance()
            
            appearance.configureWithDefaultBackground()
            appearance.backgroundColor = theme.navigationBarColor
            
            appearance.titleTextAttributes = [.foregroundColor : theme.accentColor]
            appearance.largeTitleTextAttributes = [.foregroundColor : theme.accentColor]
            
            navigationController?.navigationBar.scrollEdgeAppearance = appearance
            navigationController?.navigationBar.standardAppearance = appearance
            
        }
        
        // Style Search Controller
        
        self.cellTextColor = theme.color
        self.cellBackgroundColor = theme.backgroundColor
        self.searchController.searchBarBackgroundColor = theme.navigationBarColor
        self.searchController.keyboardAppearance = theme.statusBarStyle == .lightContent ? .dark : .light
        self.searchController.searchBar.textField?.textColor = theme.color
        self.searchController.tableView.separatorColor = .clear
        self.searchController.navigationItem.rightBarButtonItem?.tintColor = theme.accentColor
        self.searchController.tableView.backgroundColor = theme.backgroundColor
        self.searchController.separatorColor = theme.separatorColor
        self.searchController.view.backgroundColor = theme.backgroundColor
        self.searchController.navigationBarClosure = { bar in
            
            bar.barTintColor = theme.navigationBarColor
            bar.tintColor = theme.accentColor
            
        }
        
    }
    
}

extension EntryOnboardingOverviewViewController: TagListViewDelegate {
    
    func tagPressed(_ title: String, tagView: TagView, sender: TagListView) {
        
    }
    
    func tagRemoveButtonPressed(_ title: String, tagView: TagView, sender: TagListView) {
        
        sender.removeTagView(tagView)
        
        self.selectedTags.removeAll(where: { $0 == title })
        
    }
    
}

extension EntryOnboardingOverviewViewController: LFSearchViewDataSource, LFSearchViewDelegate {
    
    func searchView(_ searchView: LFSearchViewController, tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if let tag = self.searchController.searchBar?.textField?.text, tag.isNotEmptyOrWhitespace, !allLoadedTags.contains(tag) {
            return searchResultTags.count + 1
        } else {
            return searchResultTags.count
        }
        
    }
    
    func searchView(_ searchView: LFSearchViewController, didTextChangeTo text: String, textLength: Int) {
        
        if text.isEmpty {
            self.searchResultTags = allLoadedTags.map { NSAttributedString(string: $0) }
        } else {
            self.searchResultTags = searchResults(for: text)
        }
        
        searchView.reloadData()
        
    }
    
    func searchView(_ searchView: LFSearchViewController, didSelectResultAt index: Int) {
        
        if index != searchResultTags.count {
            
            let tag = searchResultTags[index].string
            
            self.addAndDisplayTagIfNotExisted(tag)
            
        } else {
            
            guard let tag = searchView.searchBar.textField?.text else { return }
            
            self.addAndDisplayTagIfNotExisted(tag)
            
        }
        
        self.searchController.searchBar?.textField?.text = ""
        
    }
    
    func searchView(_ searchView: LFSearchViewController, didSearchForText text: String) {
        
    }
    
    func searchView(_ searchView: LFSearchViewController, tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: searchView.cellIdentifier)!
        
        if indexPath.row == searchResultTags.count {
            
            if let tag = self.searchController.searchBar?.textField?.text, tag.isNotEmptyOrWhitespace, !allLoadedTags.contains(tag) {
                
                cell.textLabel?.text = String(format: String.localized("EntryOnboardingOverviewAddTagCell"), tag)
                
            }
            
        } else {
            
            cell.textLabel?.attributedText = self.searchResultTags[indexPath.row]
            
        }
        
        cell.textLabel?.textColor = self.cellTextColor
        cell.contentView.backgroundColor = self.cellBackgroundColor
        cell.selectionStyle = .none
        
        return cell
        
    }
    
}
