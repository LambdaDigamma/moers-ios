//
//  EntryOnboardingAddressViewController.swift
//  Moers
//
//  Created by Lennart Fischer on 13.10.18.
//  Copyright © 2018 Lennart Fischer. All rights reserved.
//

import Core
import UIKit

import TextFieldEffects
import MapKit

// swiftlint:disable function_body_length
class EntryOnboardingAddressViewController: UIViewController {

    lazy var scrollView = { CoreViewFactory.scrollView() }()
    lazy var contentView = { CoreViewFactory.blankView() }()
    lazy var progressView = { CoreViewFactory.onboardingProgressView() }()
    lazy var addressHeaderLabel = { CoreViewFactory.label() }()
    lazy var streetTextField = { CoreViewFactory.textField() }()
    lazy var houseNrTextField = { CoreViewFactory.textField() }()
    lazy var postcodeTextField = { CoreViewFactory.textField() }()
    lazy var placeTextField = { CoreViewFactory.textField() }()
    lazy var mapView = { CoreViewFactory.map() }()
    lazy var infoLabel = { CoreViewFactory.label() }()
    
    private var coordinate: CLLocationCoordinate2D?
    
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
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.progressView.progress = 0.2
        
        self.streetTextField.text = entryManager.entryStreet
        self.houseNrTextField.text = entryManager.entryHouseNumber
        self.postcodeTextField.text = entryManager.entryPostcode
        self.placeTextField.text = entryManager.entryPlace
        
        self.checkDataInput()
        
    }
    
    // MARK: - Private Methods
    
    private func setupUI() {
        
        self.title = String(localized: "Add entry", bundle: .module)
        
        self.view.addSubview(scrollView)
        self.scrollView.addSubview(contentView)
        self.contentView.addSubview(progressView)
        self.contentView.addSubview(addressHeaderLabel)
        self.contentView.addSubview(streetTextField)
        self.contentView.addSubview(houseNrTextField)
        self.contentView.addSubview(postcodeTextField)
        self.contentView.addSubview(placeTextField)
        self.contentView.addSubview(mapView)
        self.contentView.addSubview(infoLabel)
        
        self.progressView.currentStep = String(localized: "2. Enter address", bundle: .module)
        self.progressView.progress = 0.0
        
        self.addressHeaderLabel.text = String(localized: "Addresse", bundle: .module).uppercased()
        self.streetTextField.placeholder = String(localized: "Street", bundle: .module)
        self.houseNrTextField.placeholder = String(localized: "Number", bundle: .module)
        self.postcodeTextField.placeholder = String(localized: "Postcode", bundle: .module)
        self.placeTextField.placeholder = String(localized: "Place", bundle: .module)
        
        self.infoLabel.text = String(localized: "Enter all required information and continue.", bundle: .module)
        self.infoLabel.font = UIFont.systemFont(ofSize: 12)
        
        self.addressHeaderLabel.font = UIFont.systemFont(ofSize: 12, weight: UIFont.Weight.semibold)
        self.postcodeTextField.keyboardType = .numberPad
        
        self.streetTextField.delegate = self
        self.houseNrTextField.delegate = self
        self.postcodeTextField.delegate = self
        self.placeTextField.delegate = self
        
        self.streetTextField.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
        self.houseNrTextField.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
        self.postcodeTextField.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
        self.placeTextField.addTarget(self, action: #selector(textChanged(_:)), for: .editingChanged)
        
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
        
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
    }
    
    private func setupTheming() {
        
    }
    
    private func setupConstraints() {
        
        let constraints = [scrollView.topAnchor.constraint(equalTo: self.safeTopAnchor, constant: 0),
                           scrollView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 0),
                           scrollView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: 0),
                           scrollView.bottomAnchor.constraint(equalTo: self.safeBottomAnchor, constant: 0),
                           contentView.leadingAnchor.constraint(equalTo: self.scrollView.leadingAnchor),
                           contentView.trailingAnchor.constraint(equalTo: self.scrollView.trailingAnchor),
                           contentView.topAnchor.constraint(equalTo: self.scrollView.topAnchor),
                           contentView.bottomAnchor.constraint(equalTo: self.scrollView.bottomAnchor),
                           contentView.widthAnchor.constraint(equalTo: self.view.widthAnchor),
                           progressView.topAnchor.constraint(equalTo: self.contentView.topAnchor, constant: 20),
                           progressView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
                           progressView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
                           addressHeaderLabel.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 20),
                           addressHeaderLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
                           addressHeaderLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
                           streetTextField.topAnchor.constraint(equalTo: self.addressHeaderLabel.bottomAnchor, constant: 0),
                           streetTextField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
                           streetTextField.trailingAnchor.constraint(equalTo: self.streetTextField.leadingAnchor, constant: -16),
                           streetTextField.heightAnchor.constraint(equalToConstant: 55),
                           houseNrTextField.topAnchor.constraint(equalTo: self.streetTextField.topAnchor),
                           houseNrTextField.leadingAnchor.constraint(equalTo: self.streetTextField.trailingAnchor, constant: 8),
                           houseNrTextField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
                           houseNrTextField.heightAnchor.constraint(equalToConstant: 55),
                           houseNrTextField.widthAnchor.constraint(equalToConstant: 55),
                           postcodeTextField.topAnchor.constraint(equalTo: self.houseNrTextField.bottomAnchor, constant: 8),
                           postcodeTextField.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
                           postcodeTextField.trailingAnchor.constraint(equalTo: self.placeTextField.leadingAnchor, constant: -8),
                           postcodeTextField.heightAnchor.constraint(equalToConstant: 55),
                           postcodeTextField.widthAnchor.constraint(equalToConstant: 80),
                           placeTextField.topAnchor.constraint(equalTo: self.houseNrTextField.bottomAnchor, constant: 8),
                           placeTextField.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
                           placeTextField.heightAnchor.constraint(equalToConstant: 55),
                           mapView.topAnchor.constraint(equalTo: self.placeTextField.bottomAnchor, constant: 20),
                           mapView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
                           mapView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
                           mapView.heightAnchor.constraint(equalToConstant: 180),
                           infoLabel.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 16),
                           infoLabel.leadingAnchor.constraint(equalTo: self.view.leadingAnchor, constant: 16),
                           infoLabel.trailingAnchor.constraint(equalTo: self.view.trailingAnchor, constant: -16),
                           infoLabel.bottomAnchor.constraint(equalTo: self.contentView.bottomAnchor, constant: -50)]

        NSLayoutConstraint.activate(constraints)
        
    }
    
    // MARK: - Helper
    
    @objc private func adjustForKeyboard(notification: Notification) {
        
        guard let userInfo = notification.userInfo else { return }
        guard let keyboardScreenEndFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return }
        
        let keyboardViewEndFrame = view.convert(keyboardScreenEndFrame, from: view.window)
        
        if notification.name == UIResponder.keyboardWillHideNotification {
            scrollView.contentInset = UIEdgeInsets.zero
        } else {
            scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: keyboardViewEndFrame.height, right: 0)
        }
        
        scrollView.scrollIndicatorInsets = scrollView.contentInset
        
    }
    
    @objc private func continueOnboarding() {
        
        entryManager.entryStreet = streetTextField.text
        entryManager.entryHouseNumber = houseNrTextField.text
        entryManager.entryPostcode = postcodeTextField.text
        entryManager.entryPlace = placeTextField.text
        
        guard let coordinate = coordinate else { return }
        
        entryManager.entryLat = coordinate.latitude
        entryManager.entryLng = coordinate.longitude
        
        let viewController = EntryOnboardingGeneralViewController(entryManager: entryManager)
            
        self.navigationController?.pushViewController(viewController, animated: true)
        
    }
    
    @objc private func textChanged(_ textField: UITextField) {
        
        if streetTextField.text != "" && houseNrTextField.text != "" && postcodeTextField.text != "" && placeTextField.text != "" {
            
            self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: String(localized: "Next", bundle: .module),
                                                                     style: .plain,
                                                                     target: self,
                                                                     action: #selector(self.continueOnboarding))
            
        } else {
            
            self.invalidateUI()
            
        }
        
    }
    
    private func invalidateUI() {
        
        self.navigationItem.rightBarButtonItem = nil
        
        self.mapView.removeAnnotations(mapView.annotations)
        self.mapView.alpha = 0.5
        
    }
    
    private func startGeocodingAddress(street: String, houseNumber: String, postcode: String, place: String) {
        
        let geocoder = CLGeocoder()
        let addressString = "\(street) \(houseNumber), \(postcode) \(place)"
        
        geocoder.geocodeAddressString(addressString) { (placemarks, error) in
            
            if let error = error {
                
                self.invalidateUI()
                
                print(error.localizedDescription)
                
            }
            
            if let placemark = placemarks?.first {
                
                guard let coordinate = placemark.location?.coordinate else { return }
                
                self.coordinate = coordinate
                
                let region = MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.0025, longitudeDelta: 0.0025))
                let annotation = MKPointAnnotation()
                
                annotation.coordinate = coordinate
                
                self.mapView.removeAnnotations(self.mapView.annotations)
                self.mapView.addAnnotation(annotation)
                self.mapView.setCenter(coordinate, animated: false)
                self.mapView.setRegion(region, animated: false)
                self.mapView.alpha = 1
                
                self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: String(localized: "Next", bundle: .module),
                                                                         style: .plain,
                                                                         target: self,
                                                                         action: #selector(self.continueOnboarding))
                
            } else {
                self.invalidateUI()
            }
            
        }
        
    }
    
    private func checkDataInput() {
        
        let street = streetTextField.text ?? ""
        let houseNumber = houseNrTextField.text ?? ""
        let postcode = postcodeTextField.text ?? ""
        let place = placeTextField.text ?? ""
        
        if street != "" && houseNumber != "" && postcode != "" && place != "" {
            
            self.startGeocodingAddress(street: street,
                                       houseNumber: houseNumber,
                                       postcode: postcode,
                                       place: place)
            
        } else {
            self.invalidateUI()
        }
        
    }
    
}

extension EntryOnboardingAddressViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        guard let textField = textField as? HoshiTextField else { return }
        
        if textField === postcodeTextField {
            
            textField.setValidInput(textField.text ?? "" ~= "^(?!01000|99999)(0[1-9]\\d{3}|[1-9]\\d{4})$")
            
        } else {
            
            textField.setValidInput(!(textField.text ?? "").isEmpty)
            
        }
        
        checkDataInput()
        
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
