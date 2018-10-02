//
//  AddShopViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 26.06.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import UIKit
import Gestalt
import TextFieldEffects
import MapKit
import Alertift

struct ShopEntry {
    
    var title: String
    var branch: String
    var street: String
    var houseNr: String
    var postcode: String
    var place: String
    var coordinate: CLLocationCoordinate2D
    var website: String?
    var phone: String?
    var monday: String?
    var tuesday: String?
    var wednesday: String?
    var thursday: String?
    var friday: String?
    var saturday: String?
    var sunday: String?
    var other: String?
    
}

class AddShopViewController: UIViewController, MapLocationPickerViewControllerDelegate {

    lazy var scrollView = { return ViewFactory.scrollView() }()
    lazy var contentView = { return ViewFactory.blankView() }()
    lazy var generalHeaderLabel = { return ViewFactory.label() }()
    lazy var nameTextField = { return ViewFactory.textField() }()
    lazy var branchTextField = { return ViewFactory.textField() }()
    lazy var addressHeaderLabel = { return ViewFactory.label() }()
    lazy var streetTextField = { return ViewFactory.textField() }()
    lazy var houseNrTextField = { return ViewFactory.textField() }()
    lazy var postcodeTextField = { return ViewFactory.textField() }()
    lazy var placeTextField = { return ViewFactory.textField() }()
    lazy var mapView = { return ViewFactory.map() }()
    lazy var promptLabel = { return ViewFactory.label() }()
    lazy var contactHeaderLabel = { return ViewFactory.label() }()
    lazy var websiteTextField = { return ViewFactory.textField() }()
    lazy var phoneTextField = { return ViewFactory.textField() }()
    lazy var openingHoursHeaderLabel = { return ViewFactory.label() }()
    lazy var openingHoursStackView = { return ViewFactory.stackView() }()
    lazy var mondayOHTextField = { return ViewFactory.textField() }()
    lazy var tuesdayOHTextField = { return ViewFactory.textField() }()
    lazy var wednesdayOHTextField = { return ViewFactory.textField() }()
    lazy var thursdayOHTextField = { return ViewFactory.textField() }()
    lazy var fridayOHTextField = { return ViewFactory.textField() }()
    lazy var saturdayOHTextField = { return ViewFactory.textField() }()
    lazy var sundayOHTextField = { return ViewFactory.textField() }()
    lazy var otherOHTextField = { return ViewFactory.textField() }()
    lazy var saveButton = { return ViewFactory.button() }()
    
    var coordinate: CLLocationCoordinate2D? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = String.localized("AddTitle")
        
        self.view.addSubview(scrollView)
        self.scrollView.addSubview(contentView)
        self.contentView.addSubview(generalHeaderLabel)
        self.contentView.addSubview(nameTextField)
        self.contentView.addSubview(branchTextField)
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
        
        self.setupUI()
        self.setupConstraints()
        self.setupTheming()
        self.addPromptLabel()
        self.setupOpeningHours()
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        self.mapView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(choosePosition)))
        
    }
    
    private func setupUI() {
        
        // TODO: Add Localization
        
        self.generalHeaderLabel.text = "ALLGEMEINES"
        self.nameTextField.placeholder = "Name"
        self.branchTextField.placeholder = "Branche"
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
        
        self.nameTextField.delegate = self
        self.branchTextField.delegate = self
        self.streetTextField.delegate = self
        self.houseNrTextField.delegate = self
        self.postcodeTextField.delegate = self
        self.placeTextField.delegate = self
        self.websiteTextField.delegate = self
        self.phoneTextField.delegate = self
        self.mondayOHTextField.delegate = self
        self.tuesdayOHTextField.delegate = self
        self.wednesdayOHTextField.delegate = self
        self.thursdayOHTextField.delegate = self
        self.fridayOHTextField.delegate = self
        self.saturdayOHTextField.delegate = self
        self.sundayOHTextField.delegate = self
        self.otherOHTextField.delegate = self
        
        self.generalHeaderLabel.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.semibold)
        self.addressHeaderLabel.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.semibold)
        self.contactHeaderLabel.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.semibold)
        self.openingHoursHeaderLabel.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.semibold)
        
        self.postcodeTextField.keyboardType = .numberPad
        self.websiteTextField.keyboardType = .URL
        self.phoneTextField.keyboardType = .phonePad
        
        let coordinate = CLLocationCoordinate2D(latitude: 51.4516, longitude: 6.6255)
        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.0025, longitudeDelta: 0.0025)) // 0.0015
        
        self.mapView.setCenter(coordinate, animated: false)
        self.mapView.isScrollEnabled = false
        self.mapView.isZoomEnabled = false
        self.mapView.isPitchEnabled = false
        self.mapView.isRotateEnabled = false
        self.mapView.showsCompass = false
        self.mapView.alpha = 0.5
        self.mapView.region = region
        
        self.saveButton.layer.cornerRadius = 8
        self.saveButton.clipsToBounds = true
        self.saveButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.bold)
        self.saveButton.addTarget(self, action: #selector(saveShop), for: .touchUpInside)
        
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
                           branchTextField.topAnchor.constraint(equalTo: self.nameTextField.bottomAnchor, constant: 8),
                           branchTextField.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16),
                           branchTextField.rightAnchor.constraint(equalTo: self.view.rightAnchor, constant: -16),
                           branchTextField.heightAnchor.constraint(equalToConstant: 55),
                           addressHeaderLabel.topAnchor.constraint(equalTo: self.branchTextField.bottomAnchor, constant: 16),
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
                
                textField.borderActiveColor = theme.accentColor
                textField.borderInactiveColor = theme.decentColor
                textField.placeholderColor = theme.color
                textField.textColor = theme.color
                textField.tintColor = theme.accentColor
                textField.keyboardAppearance = theme.statusBarStyle == .lightContent ? .dark : .light
                textField.autocorrectionType = .no
                
            }
            
            themeable.view.backgroundColor = theme.backgroundColor
            themeable.generalHeaderLabel.textColor = theme.decentColor
            themeable.addressHeaderLabel.textColor = theme.decentColor
            themeable.contactHeaderLabel.textColor = theme.decentColor
            themeable.openingHoursHeaderLabel.textColor = theme.decentColor
            themeable.promptLabel.textColor = theme.color
            
            themeable.mapView.layer.cornerRadius = 10
            themeable.saveButton.setTitleColor(theme.backgroundColor, for: .normal)
            themeable.saveButton.setBackgroundColor(color: theme.accentColor, forState: .normal)
            themeable.saveButton.setBackgroundColor(color: theme.accentColor.darker(by: 10)!, forState: .selected)
            
            applyTheming(themeable.nameTextField)
            applyTheming(themeable.branchTextField)
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
    
    @objc func choosePosition() {
        
        let locationPicker = MapLocationPickerViewController()
        
        locationPicker.delegate = self
        
        navigationController?.pushViewController(locationPicker, animated: true)
        
    }
    
    @objc func saveShop() {
        
        guard let name = nameTextField.text,
              let branch = branchTextField.text,
              let street = streetTextField.text,
              let houseNr = houseNrTextField.text,
              let postcode = postcodeTextField.text,
              let place = placeTextField.text,
              let coordinate = coordinate else {
                
                self.alertMissingInformation()
                return
                
              }
        
        if name != "" && street != "" && houseNr != "" && postcode != "" && place != "" {
            
            let shopEntry = ShopEntry(title: name,
                                      branch: branch,
                                      street: street,
                                      houseNr: houseNr,
                                      postcode: postcode,
                                      place: place,
                                      coordinate: coordinate,
                                      website: websiteTextField.text,
                                      phone: phoneTextField.text,
                                      monday: mondayOHTextField.text,
                                      tuesday: tuesdayOHTextField.text,
                                      wednesday: wednesdayOHTextField.text,
                                      thursday: thursdayOHTextField.text,
                                      friday: fridayOHTextField.text,
                                      saturday: saturdayOHTextField.text,
                                      sunday: sundayOHTextField.text,
                                      other: otherOHTextField.text)
            
            API.shared.storeShop(shopEntry: shopEntry) { (error, success) in
                
                if let error = error as? APIError {
                    print(error.localizedDescription)
                    
                    if error == APIError.noToken {
                        self.alertNoToken()
                    } else {
                        self.alertError()
                    }
                    
                }
                
                guard let success = success else { self.alertError(); return }
                
                if success {
                    self.alertSuccess()
                } else {
                    self.alertError()
                }
                
            }
            
        } else {
            
            self.alertMissingInformation()
            
        }
        
    }
    
    private func alertMissingInformation() {
        
        Alertift.alert(title: "Angaben fehlen", message: "Erforderliche Angaben wurden nicht eingetragen!")
            .titleTextColor(branchTextField.textColor)
            .messageTextColor(branchTextField.textColor)
            .buttonTextColor(branchTextField.textColor)
            .backgroundColor(view.backgroundColor)
            .action(.default("Okay"), handler: { (action, i, textFields) in
                
            })
            .show()
        
    }
    
    private func alertError() {
        
        Alertift.alert(title: "Ein Fehler ist aufgetreten", message: "Ein unbekannter Fehler ist aufgetreten.")
            .titleTextColor(branchTextField.textColor)
            .messageTextColor(branchTextField.textColor)
            .buttonTextColor(branchTextField.textColor)
            .backgroundColor(view.backgroundColor)
            .action(.default("Okay"), handler: { (action, i, textFields) in
                
            })
            .show()
        
    }
    
    private func alertSuccess() {
        
        Alertift.alert(title: "Geschäft erfolgreich hinzugefügt", message: "Vielen Dank für Deinen Beitrag!\nDein Eintrag wird einer kurzen Prüfung unterzogen und dann für die Karte freigeschaltet!")
            .titleTextColor(branchTextField.textColor)
            .messageTextColor(branchTextField.textColor)
            .buttonTextColor(branchTextField.textColor)
            .backgroundColor(view.backgroundColor)
            .action(.default("Okay"), handler: { (action, i, textFields) in
                self.navigationController?.popViewController(animated: true)
            })
            .show()
        
    }
    
    private func addPromptLabel() {
        
        self.contentView.addSubview(promptLabel)
        
        promptLabel.text = "Wähle die genaue Position aus!"
        promptLabel.textAlignment = .center
        promptLabel.numberOfLines = 0
        promptLabel.font = UIFont.systemFont(ofSize: 16, weight: UIFont.Weight.semibold)
        promptLabel.centerXAnchor.constraint(equalTo: self.mapView.centerXAnchor).isActive = true
        promptLabel.centerYAnchor.constraint(equalTo: self.mapView.centerYAnchor).isActive = true
        promptLabel.leftAnchor.constraint(equalTo: self.mapView.leftAnchor, constant: 8).isActive = true
        promptLabel.rightAnchor.constraint(equalTo: self.mapView.rightAnchor, constant: -8).isActive = true
        
    }
    
    func selectedCoordinate(_ coordinate: CLLocationCoordinate2D) {
        
        promptLabel.removeFromSuperview()
        
        self.coordinate = coordinate
        
        let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.0025, longitudeDelta: 0.0025))
        let annotation = MKPointAnnotation()
        
        annotation.coordinate = coordinate
        
        self.mapView.removeAnnotations(mapView.annotations)
        self.mapView.addAnnotation(annotation)
        self.mapView.setCenter(coordinate, animated: false)
        self.mapView.setRegion(region, animated: false)
        self.mapView.alpha = 1
        
    }
    
}

extension AddShopViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        guard let textField = textField as? HoshiTextField else { return }
        
        if textField === nameTextField {
            
            textField.setValidInput((textField.text ?? "").count >= 4)
            
        } else if textField === branchTextField {
            
            textField.setValidInput((textField.text ?? "").count >= 4)
            
        } else if textField === postcodeTextField {
            
            textField.setValidInput(textField.text ?? "" ~= "^(?!01000|99999)(0[1-9]\\d{3}|[1-9]\\d{4})$")
            
        } else if textField === websiteTextField {
            
            if (textField.text ?? "").count != 0 {
                textField.setValidInput(textField.text ?? "" ~= "[-a-zA-Z0-9@:%._\\+~#=]{2,256}\\.[a-z]{2,6}\\b([-a-zA-Z0-9@:%_\\+.~#?&//=]*)")
            }
            
        } else {
            
            if (textField.text ?? "").count != 0 {
                textField.setValidInput(true)
            }
            
        }
        
    }
    
}

extension HoshiTextField {
    
    public func setValidInput(_ isValid: Bool) {
        
        if isValid {
            self.borderInactiveColor = UIColor.green
        } else {
            self.borderInactiveColor = UIColor.red
        }
        
    }
    
}
