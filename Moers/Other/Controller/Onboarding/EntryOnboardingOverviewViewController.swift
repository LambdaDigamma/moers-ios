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

enum EntryOverviewType: Equatable {
    case summary
    case edit(entry: Entry)
}

class EntryOnboardingOverviewViewController: UIViewController {

    lazy var scrollView = { ViewFactory.scrollView() }()
    lazy var contentView = { ViewFactory.blankView() }()
    lazy var generalHeaderLabel = { ViewFactory.label() }()
    lazy var nameTextField = { ViewFactory.textField() }()
    lazy var tagsHeaderLabel = { ViewFactory.label() }()
    lazy var tagsListView = { ViewFactory.tagListView() }()
    lazy var addressHeaderLabel = { ViewFactory.label() }()
    lazy var streetTextField = { ViewFactory.textField() }()
    lazy var houseNrTextField = { ViewFactory.textField() }()
    lazy var postcodeTextField = { ViewFactory.textField() }()
    lazy var placeTextField = { ViewFactory.textField() }()
    lazy var mapView = { ViewFactory.map() }()
    lazy var promptLabel = { ViewFactory.label() }()
    lazy var contactHeaderLabel = { ViewFactory.label() }()
    lazy var websiteTextField = { ViewFactory.textField() }()
    lazy var phoneTextField = { ViewFactory.textField() }()
    lazy var openingHoursHeaderLabel = { ViewFactory.label() }()
    lazy var openingHoursStackView = { ViewFactory.stackView() }()
    lazy var mondayOHTextField = { ViewFactory.textField() }()
    lazy var tuesdayOHTextField = { ViewFactory.textField() }()
    lazy var wednesdayOHTextField = { ViewFactory.textField() }()
    lazy var thursdayOHTextField = { ViewFactory.textField() }()
    lazy var fridayOHTextField = { ViewFactory.textField() }()
    lazy var saturdayOHTextField = { ViewFactory.textField() }()
    lazy var sundayOHTextField = { ViewFactory.textField() }()
    lazy var otherOHTextField = { ViewFactory.textField() }()
    lazy var saveButton = { ViewFactory.button() }()
    
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
        self.fillData()
        self.setupTheming()
        
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        
        if overviewType == .summary {
            self.title = "Zusammenfassung"
        } else {
            self.title = "Bearbeiten"
        }
        
        self.view.addSubview(scrollView)
        self.scrollView.addSubview(contentView)
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
        
        self.generalHeaderLabel.text = "ALLGEMEINES"
        self.nameTextField.placeholder = "Name"
        self.tagsHeaderLabel.text = "SCHLAGWORTE"
        self.addressHeaderLabel.text = "ADRESSE"
        self.streetTextField.placeholder = "Straße"
        self.houseNrTextField.placeholder = "Nr"
        self.postcodeTextField.placeholder = "PLZ"
        self.placeTextField.placeholder = "Ort"
        self.contactHeaderLabel.text = "KONTAKT"
        self.websiteTextField.placeholder = "Webseite"
        self.phoneTextField.placeholder = "Telefon"
        self.openingHoursHeaderLabel.text = "ÖFFNUNGSZEITEN"
        self.mondayOHTextField.placeholder = "Montag"
        self.tuesdayOHTextField.placeholder = "Dienstag"
        self.wednesdayOHTextField.placeholder = "Mittwoch"
        self.thursdayOHTextField.placeholder = "Donnerstag"
        self.fridayOHTextField.placeholder = "Freitag"
        self.saturdayOHTextField.placeholder = "Samstag"
        self.sundayOHTextField.placeholder = "Sonntag"
        self.otherOHTextField.placeholder = "Sonstiges"
        
        if overviewType == EntryOverviewType.summary {
            self.saveButton.setTitle("Hinzufügen", for: .normal)
        } else {
            self.saveButton.setTitle("Aktualisieren", for: .normal)
        }
        
        self.tagsListView.enableRemoveButton = false
        
        self.generalHeaderLabel.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.semibold)
        self.tagsHeaderLabel.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.semibold)
        self.addressHeaderLabel.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.semibold)
        self.contactHeaderLabel.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.semibold)
        self.openingHoursHeaderLabel.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.semibold)
        
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
                           generalHeaderLabel.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 16),
                           generalHeaderLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16),
                           generalHeaderLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16),
                           nameTextField.topAnchor.constraint(equalTo: self.generalHeaderLabel.bottomAnchor, constant: 0),
                           nameTextField.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16),
                           nameTextField.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16),
                           nameTextField.heightAnchor.constraint(equalToConstant: 55),
                           tagsHeaderLabel.topAnchor.constraint(equalTo: self.nameTextField.bottomAnchor, constant: 16),
                           tagsHeaderLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16),
                           tagsHeaderLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16),
                           tagsListView.topAnchor.constraint(equalTo: self.tagsHeaderLabel.bottomAnchor, constant: 8),
                           tagsListView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16),
                           tagsListView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16),
                           addressHeaderLabel.topAnchor.constraint(equalTo: self.tagsListView.bottomAnchor, constant: 16),
                           addressHeaderLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16),
                           addressHeaderLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16),
                           streetTextField.topAnchor.constraint(equalTo: self.addressHeaderLabel.bottomAnchor, constant: 0),
                           streetTextField.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16),
                           streetTextField.rightAnchor.constraint(equalTo: self.streetTextField.leftAnchor, constant: -16),
                           streetTextField.heightAnchor.constraint(equalToConstant: 55),
                           houseNrTextField.topAnchor.constraint(equalTo: self.streetTextField.topAnchor),
                           houseNrTextField.leftAnchor.constraint(equalTo: self.streetTextField.rightAnchor, constant: 8),
                           houseNrTextField.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16),
                           houseNrTextField.heightAnchor.constraint(equalToConstant: 55),
                           houseNrTextField.widthAnchor.constraint(equalToConstant: 55),
                           postcodeTextField.topAnchor.constraint(equalTo: self.houseNrTextField.bottomAnchor, constant: 8),
                           postcodeTextField.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16),
                           postcodeTextField.rightAnchor.constraint(equalTo: self.placeTextField.leftAnchor, constant: -8),
                           postcodeTextField.heightAnchor.constraint(equalToConstant: 55),
                           postcodeTextField.widthAnchor.constraint(equalToConstant: 80),
                           placeTextField.topAnchor.constraint(equalTo: self.houseNrTextField.bottomAnchor, constant: 8),
                           placeTextField.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16),
                           placeTextField.heightAnchor.constraint(equalToConstant: 55),
                           mapView.topAnchor.constraint(equalTo: self.placeTextField.bottomAnchor, constant: 20),
                           mapView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16),
                           mapView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16),
                           mapView.heightAnchor.constraint(equalToConstant: 180),
                           contactHeaderLabel.topAnchor.constraint(equalTo: self.mapView.bottomAnchor, constant: 20),
                           contactHeaderLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16),
                           contactHeaderLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16),
                           websiteTextField.topAnchor.constraint(equalTo: self.contactHeaderLabel.bottomAnchor, constant: 0),
                           websiteTextField.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16),
                           websiteTextField.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16),
                           websiteTextField.heightAnchor.constraint(equalToConstant: 55),
                           phoneTextField.topAnchor.constraint(equalTo: self.websiteTextField.bottomAnchor, constant: 16),
                           phoneTextField.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16),
                           phoneTextField.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16),
                           phoneTextField.heightAnchor.constraint(equalToConstant: 55),
                           openingHoursHeaderLabel.topAnchor.constraint(equalTo: phoneTextField.bottomAnchor, constant: 16),
                           openingHoursHeaderLabel.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16),
                           openingHoursHeaderLabel.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16),
                           mondayOHTextField.heightAnchor.constraint(equalToConstant: 55),
                           tuesdayOHTextField.heightAnchor.constraint(equalToConstant: 55),
                           wednesdayOHTextField.heightAnchor.constraint(equalToConstant: 55),
                           thursdayOHTextField.heightAnchor.constraint(equalToConstant: 55),
                           fridayOHTextField.heightAnchor.constraint(equalToConstant: 55),
                           saturdayOHTextField.heightAnchor.constraint(equalToConstant: 55),
                           sundayOHTextField.heightAnchor.constraint(equalToConstant: 55),
                           otherOHTextField.heightAnchor.constraint(equalToConstant: 55),
                           openingHoursStackView.topAnchor.constraint(equalTo: openingHoursHeaderLabel.bottomAnchor, constant: 0),
                           openingHoursStackView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16),
                           openingHoursStackView.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16),
                           saveButton.topAnchor.constraint(equalTo: self.openingHoursStackView.bottomAnchor, constant: 16),
                           saveButton.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16),
                           saveButton.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16),
                           saveButton.heightAnchor.constraint(equalToConstant: 45),
                           saveButton.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -50)]
        
        NSLayoutConstraint.activate(constraints)
        
    }
    
    private func setupTheming() {
        
        MMUIConfig.themeManager?.manage(theme: \Theme.self, for: self)
        
    }
    
    private func setupOpeningHours() {
        
        let columnStackView: ((HoshiTextField, HoshiTextField) -> UIStackView) = { textField1, textField2 in
            
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
    
    private func fillData() {
        
        switch overviewType {
        case .summary:
            
            self.setupSummary()
            
        case .edit(let entry):
            
            self.setupEdit(with: entry)
            
        }
        
    }
    
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
        
        disableTextFields([nameTextField, phoneTextField, websiteTextField, streetTextField, houseNrTextField, postcodeTextField, placeTextField, mondayOHTextField, tuesdayOHTextField, wednesdayOHTextField, thursdayOHTextField, fridayOHTextField, saturdayOHTextField, sundayOHTextField, otherOHTextField])
        
        let coordinate = CLLocationCoordinate2D(latitude: entryManager.entryLat ?? 0, longitude: entryManager.entryLng ?? 0)
        
        self.setupMap(with: coordinate)
        self.setupTags(with: entryManager.entryTags)
        
    }
    
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
        
        // TODO: Add Another Tag for Adding Tags
        
    }
    
    private func disableTextFields(_ textFields: [UITextField]) {
        textFields.forEach { $0.isEnabled = false }
    }
    
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
                
                self.alertSuccess()
                self.entryManager.resetData()
                
                guard let tabBarController = self.tabBarController as? TabBarController else { return }
                
                tabBarController.mainViewController.addLocation(entry)
                
            case .failure(let error):
                
                print(error.localizedDescription)
                
                if let error = error as? APIError, error == .notAuthorized {
                    self.alertNotAuthorized()
                    return
                }
                
                self.alertError()
                
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
                    
                    if let error = error as? APIError, error == .notAuthorized {
                        self.alertNotAuthorized()
                        return
                    }
                    
                    self.alertError()
                    
                }
                
            }
            
        }
        
    }
    
    // MARK: - Alerts
    
    @objc private func alertConfirm() {
        
        Alertift.alert(title: "Bist Du sicher?", message: "Willst Du diesen Eintrag wirklich \(overviewType == .summary ? "hinzufügen" : "ändern")? Achte darauf, dass Du auch wirklich die richtigen Informationen eingetragen hast. Nur so können andere davon profitieren!")
            .titleTextColor(nameTextField.textColor)
            .messageTextColor(nameTextField.textColor)
            .buttonTextColor(nameTextField.textColor)
            .backgroundColor(view.backgroundColor)
            .action(Alertift.Action.cancel("Nein"), handler: { (action, i, textFields) in
                
            })
            .action(.default("Ja"), isPreferred: true, handler: { (action, i, textFields) in
                
                self.save()
                
            })
            .show()
        
    }
    
    private func alertSuccess() {
        
        Alertift.alert(title: "Eintrag \(overviewType == .summary ? "hinzugefügt" : "geändert")!", message: "Vielen Dank für Deinen Beitrag!\nDein Eintrag ist jetzt auf der Karte zu finden!")
            .titleTextColor(nameTextField.textColor)
            .messageTextColor(nameTextField.textColor)
            .buttonTextColor(nameTextField.textColor)
            .backgroundColor(view.backgroundColor)
            .action(.default("Okay"), handler: { (action, i, textFields) in
                
                if self.overviewType == .summary {
                    
                    guard let otherVC = self.navigationController?.children.first else { return }
                    
                    self.navigationController?.popToViewController(otherVC, animated: true)
                    
                } else {
                    
                    self.navigationController?.popViewController(animated: true)
                    
                }
                
            })
            .show()
        
    }
    
    private func alertError() {
        
        Alertift.alert(title: "Ein Fehler ist aufgetreten", message: "Ein unbekannter Fehler ist aufgetreten.")
            .titleTextColor(nameTextField.textColor)
            .messageTextColor(nameTextField.textColor)
            .buttonTextColor(nameTextField.textColor)
            .backgroundColor(view.backgroundColor)
            .action(.default("Okay"), handler: { (action, i, textFields) in
                
            })
            .show()
        
    }
    
    private func alertNotAuthorized() {
        
        Alertift.alert(title: "Nicht authorisiert!", message: "Das Hinzufügen von Einträgen wurde aufgrund von Missbrauch zwischenzeitlich bis auf weiteres geschlossen.")
            .titleTextColor(nameTextField.textColor)
            .messageTextColor(nameTextField.textColor)
            .buttonTextColor(nameTextField.textColor)
            .backgroundColor(view.backgroundColor)
            .action(.default("Okay"), handler: { (action, i, textFields) in
                
                guard let otherVC = self.navigationController?.children.first else { return }
                
                self.navigationController?.popToViewController(otherVC, animated: true)
                
            })
            .show()
        
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
        
        let applyTheming: ((HoshiTextField) -> Void) = { textField in
            
            if textField.isEnabled {
                textField.borderActiveColor = theme.accentColor
            } else {
                textField.borderActiveColor = theme.decentColor
            }
            
            textField.borderInactiveColor = theme.decentColor
            textField.placeholderColor = theme.color
            textField.textColor = theme.color.darker(by: 10)
            textField.tintColor = theme.accentColor
            textField.keyboardAppearance = theme.statusBarStyle == .lightContent ? .dark : .light
            textField.autocorrectionType = .no
            textField.delegate = self
            
        }
        
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
        
        applyTheming(self.nameTextField)
        applyTheming(self.streetTextField)
        applyTheming(self.houseNrTextField)
        applyTheming(self.postcodeTextField)
        applyTheming(self.placeTextField)
        applyTheming(self.websiteTextField)
        applyTheming(self.phoneTextField)
        applyTheming(self.mondayOHTextField)
        applyTheming(self.tuesdayOHTextField)
        applyTheming(self.wednesdayOHTextField)
        applyTheming(self.thursdayOHTextField)
        applyTheming(self.fridayOHTextField)
        applyTheming(self.saturdayOHTextField)
        applyTheming(self.sundayOHTextField)
        applyTheming(self.otherOHTextField)
        
    }
    
}
