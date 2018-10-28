//
//  EntryOnboardingSummaryViewController.swift
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

class EntryOnboardingSummaryViewController: UIViewController {

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
    
    // MARK: - UIViewController Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.setupUI()
        self.setupConstraints()
        self.setupTheming()
        self.setupOpeningHours()
        self.fillData()
        
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        
        self.title = "Zusammenfassung"
        
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
        self.saveButton.setTitle("Einsenden", for: .normal)
        
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
        self.saveButton.addTarget(self, action: #selector(save), for: .touchUpInside)
        
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
        
        ThemeManager.default.apply(theme: Theme.self, to: self) { (themeable, theme) in
            
            let applyTheming: ((HoshiTextField) -> Void) = { textField in
                
                textField.borderActiveColor = theme.decentColor
                textField.borderInactiveColor = theme.decentColor
                textField.placeholderColor = theme.color
                textField.textColor = theme.color.darker(by: 10)
                textField.tintColor = theme.accentColor
                textField.keyboardAppearance = theme.statusBarStyle == .lightContent ? .dark : .light
                textField.autocorrectionType = .no
                
            }
            
            themeable.view.backgroundColor = theme.backgroundColor
            themeable.generalHeaderLabel.textColor = theme.decentColor
            themeable.tagsHeaderLabel.textColor = theme.decentColor
            themeable.addressHeaderLabel.textColor = theme.decentColor
            themeable.contactHeaderLabel.textColor = theme.decentColor
            themeable.openingHoursHeaderLabel.textColor = theme.decentColor
            themeable.promptLabel.textColor = theme.color
            themeable.tagsListView.tagBackgroundColor = theme.accentColor
            themeable.tagsListView.textColor = theme.backgroundColor
            themeable.tagsListView.removeIconLineColor = theme.backgroundColor
            
            themeable.mapView.layer.cornerRadius = 10
            themeable.saveButton.setTitleColor(theme.backgroundColor, for: .normal)
            themeable.saveButton.setBackgroundColor(color: theme.accentColor, forState: .normal)
            themeable.saveButton.setBackgroundColor(color: theme.accentColor.darker(by: 10)!, forState: .selected)
            
            applyTheming(themeable.nameTextField)
            applyTheming(themeable.streetTextField)
            applyTheming(themeable.houseNrTextField)
            applyTheming(themeable.postcodeTextField)
            applyTheming(themeable.placeTextField)
            applyTheming(themeable.websiteTextField)
            applyTheming(themeable.phoneTextField)
            applyTheming(themeable.mondayOHTextField)
            applyTheming(themeable.tuesdayOHTextField)
            applyTheming(themeable.wednesdayOHTextField)
            applyTheming(themeable.thursdayOHTextField)
            applyTheming(themeable.fridayOHTextField)
            applyTheming(themeable.saturdayOHTextField)
            applyTheming(themeable.sundayOHTextField)
            applyTheming(themeable.otherOHTextField)
            
        }

        
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
        
        func disableTextFields(_ textFields: [UITextField]) {
            textFields.forEach { $0.isEnabled = false }
        }
        
        self.nameTextField.text = EntryManager.shared.entryName
        self.phoneTextField.text = EntryManager.shared.entryPhone
        self.websiteTextField.text = EntryManager.shared.entryWebsite
        self.streetTextField.text = EntryManager.shared.entryStreet
        self.houseNrTextField.text = EntryManager.shared.entryHouseNumber
        self.postcodeTextField.text = EntryManager.shared.entryPostcode
        self.placeTextField.text = EntryManager.shared.entryPlace
        self.mondayOHTextField.text = EntryManager.shared.entryMondayOH
        self.tuesdayOHTextField.text = EntryManager.shared.entryTuesdayOH
        self.wednesdayOHTextField.text = EntryManager.shared.entryWednesdayOH
        self.thursdayOHTextField.text = EntryManager.shared.entryThursdayOH
        self.fridayOHTextField.text = EntryManager.shared.entryFridayOH
        self.saturdayOHTextField.text = EntryManager.shared.entrySaturdayOH
        self.sundayOHTextField.text = EntryManager.shared.entrySundayOH
        self.otherOHTextField.text = EntryManager.shared.entryOtherOH
        
        disableTextFields([nameTextField, phoneTextField, websiteTextField, streetTextField, houseNrTextField, postcodeTextField, placeTextField, mondayOHTextField, tuesdayOHTextField, wednesdayOHTextField, thursdayOHTextField, fridayOHTextField, saturdayOHTextField, sundayOHTextField, otherOHTextField])
        
        
        let coordinate = CLLocationCoordinate2D(latitude: EntryManager.shared.entryLat ?? 0, longitude: EntryManager.shared.entryLng ?? 0)
        
        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.0025, longitudeDelta: 0.0025))
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = coordinate
        
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.mapView.addAnnotation(annotation)
        self.mapView.setCenter(coordinate, animated: false)
        self.mapView.setRegion(region, animated: false)
        self.mapView.alpha = 1
        
        self.tagsListView.removeAllTags()
        
        EntryManager.shared.entryTags.forEach { tag in
            
            let index = self.tagsListView.tagViews.count
            
            self.tagsListView.insertTag(tag, at: index)
            
        }
        
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        
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
    
    @objc func save() {
        
        let entry = Entry(id: -1,
                          name: EntryManager.shared.entryName ?? "",
                          tags: EntryManager.shared.entryTags,
                          street: EntryManager.shared.entryStreet ?? "",
                          houseNumber: EntryManager.shared.entryHouseNumber ?? "",
                          postcode: EntryManager.shared.entryPostcode ?? "",
                          place: EntryManager.shared.entryPlace ?? "",
                          url: EntryManager.shared.entryWebsite,
                          phone: EntryManager.shared.entryPhone,
                          monday: EntryManager.shared.entryMondayOH,
                          tuesday: EntryManager.shared.entryTuesdayOH,
                          wednesday: EntryManager.shared.entryWednesdayOH,
                          thursday: EntryManager.shared.entryThursdayOH,
                          friday: EntryManager.shared.entryFridayOH,
                          saturday: EntryManager.shared.entrySaturdayOH,
                          sunday: EntryManager.shared.entrySundayOH,
                          other: EntryManager.shared.entryOtherOH,
                          lat: EntryManager.shared.entryLat ?? 0,
                          lng: EntryManager.shared.entryLng ?? 0,
                          isValidated: false,
                          createdAt: nil,
                          updatedAt: nil)
        
        EntryManager.shared.store(entry: entry) { (error, success, id) in
            
            if let error = error as? APIError, error == .notAuthorized {
                self.alertNotAuthorized()
                return
            }
            
            // TODO: Add Entry to Map and Drawer
            
            guard let success = success else { return }
            
            if success {
                
                self.alertSuccess()
                
                EntryManager.shared.resetData()
                
            } else {
                self.alertError()
            }
            
        }
        
    }
    
    private func alertSuccess() {
        
        Alertift.alert(title: "Eintrag hinzugefügt!", message: "Vielen Dank für Deinen Beitrag!\nDein Eintrag wurde zwar noch nicht von einem anderen Benutzer bestätigt, aber ist schon auf der Karte zu sehen!")
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
