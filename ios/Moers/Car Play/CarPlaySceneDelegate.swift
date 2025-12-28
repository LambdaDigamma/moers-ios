//
//  CarPlaySceneDelegate.swift
//  Moers
//
//  Created by Lennart Fischer on 09.06.22.
//  Copyright © 2022 Lennart Fischer. All rights reserved.
//

import Core
import Factory
import ParkingFeature
import FuelFeature
import CarPlay

public class CarPlaySceneDelegate: UIResponder {
    
    private var scene: CPTemplateApplicationScene?
    
    public var interfaceController: CPInterfaceController?
    
    public let parkingAreasTemplate: CPListTemplate = CPListTemplate(title: "Parkplätze", sections: [])
    public let fuelStationsTemplate: CPListTemplate = CPListTemplate(title: "Tankstellen", sections: [])
    
    // MARK: - Parking Areas -
    
    public var parkingAreas: [ParkingArea] = [] {
        didSet {
            updateParkingAreaSection()
        }
    }
    
    public func loadParkingLots() {
        
        Task {
            do {
                let parkingService = Container.shared.parkingService()
                let areas = try await parkingService.loadParkingAreas()
                
                await MainActor.run {
                    self.parkingAreas = areas
                }
            } catch {
                print("Error loading parking areas: \(error.localizedDescription)")
            }
        }
        
    }
    
    private func updateParkingAreaSection() {
        
        let openParkingAreas = parkingAreas.filter({ $0.currentOpeningState == .open })
        let closedParkingAreas = parkingAreas.filter({ [ParkingAreaOpeningState.closed, ParkingAreaOpeningState.unknown].contains($0.currentOpeningState) })
        
        let openItems = openParkingAreas.map({ (parkingArea: ParkingArea) -> CPListItem in
            let listItem = CPListItem(
                text: parkingArea.name,
                detailText: "\(parkingArea.freeSites)/\(parkingArea.capacity ?? 0) frei · \(parkingArea.currentOpeningState.name)",
                image: nil,
                accessoryImage: nil,
                accessoryType: .disclosureIndicator
            )
            
            listItem.handler = { [weak self] (item, completion) in
                guard let strongSelf = self else { return }
                strongSelf.showParkingArea(parkingArea: parkingArea, completion: completion)
            }
            
            return listItem
        })
        
        let closedItems = closedParkingAreas.map({ (parkingArea: ParkingArea) -> CPListItem in
            let listItem = CPListItem(
                text: parkingArea.name,
                detailText: "\(parkingArea.freeSites)/\(parkingArea.capacity ?? 0) frei · \(parkingArea.currentOpeningState.name)",
                image: nil,
                accessoryImage: nil,
                accessoryType: .disclosureIndicator
            )
            
            listItem.handler = { [weak self] (item, completion) in
                guard let strongSelf = self else { return }
                strongSelf.showParkingArea(parkingArea: parkingArea, completion: completion)
            }
            
            return listItem
        })
        
        
        let openSection = CPListSection(items: openItems, header: "Geöffnet", sectionIndexTitle: nil)
        let closedSection = CPListSection(items: closedItems, header: "Geschlossen / unbekannt", sectionIndexTitle: nil)
        
        self.parkingAreasTemplate.updateSections([openSection, closedSection])
        
    }
    
    private func showParkingArea(parkingArea: ParkingArea, completion: @escaping () -> Void) {
        
        let information = CPInformationTemplate(
            title: parkingArea.name,
            layout: .leading,
            items: [
                CPInformationItem(title: "Name", detail: parkingArea.name),
                CPInformationItem(title: "Freie Parkplätze", detail: "\(parkingArea.freeSites)"),
                CPInformationItem(title: "Kapazität (gesamt)", detail: parkingArea.capacity != nil ? "\(parkingArea.capacity ?? 0)" : "n/v"),
                CPInformationItem(title: "Status", detail: parkingArea.currentOpeningState.name)
            ],
            actions: [
                CPTextButton(title: "Navigation starten", textStyle: .confirm, handler: { [weak self] (_: CPTextButton) in
                    
                    guard let strongSelf = self else { return }
                    guard let point = parkingArea.location else { return }
                    guard let url = AppleNavigationProvider().buildDrivingMapsURL(point: point) else { return }
                    
                    strongSelf.scene?.open(url, options: nil)
                    
                })
            ]
        )
        
        interfaceController?.pushTemplate(information, animated: true, completion: { (result: Bool, error: Error?) in
            completion()
        })
        
    }
    
    private func showFuelStation(fuelStation: PetrolStation, completion: @escaping () -> Void) {
        
        let information = CPInformationTemplate(
            title: fuelStation.name,
            layout: .leading,
            items: [
                CPInformationItem(title: "Name", detail: fuelStation.name),
                CPInformationItem(title: "Preis", detail: "\(fuelStation.price ?? 0)€"),
                CPInformationItem(title: "Straße", detail: "\(fuelStation.street) \(fuelStation.houseNumber ?? "")"),
                CPInformationItem(title: "Ort", detail: "\(fuelStation.postCode ?? 0) \(fuelStation.place)"),
//                CPInformationItem(title: "Kapazität (gesamt)", detail: parkingArea.capacity != nil ? "\(parkingArea.capacity ?? 0)" : "n/v"),
//                CPInformationItem(title: "Status", detail: parkingArea.currentOpeningState.name)
            ],
            actions: [
                CPTextButton(title: "Navigation starten", textStyle: .confirm, handler: { [weak self] (_: CPTextButton) in
                    
                    guard let strongSelf = self else { return }
                    let point = fuelStation.coordinate.toPoint()
                    guard let url = AppleNavigationProvider().buildDrivingMapsURL(point: point) else { return }
                    
                    strongSelf.scene?.open(url, options: nil)
                    
                })
            ]
        )
        
        interfaceController?.pushTemplate(information, animated: true, completion: { (result: Bool, error: Error?) in
            completion()
        })
        
    }
    
    // MARK: - Fuel -
    
    public var fuelStations: [PetrolStation] = [] {
        didSet {
            updateFuelStationSection()
        }
    }
    
    public func loadFuelStations() {
        
        Task {
            do {
                let locationService = Container.shared.locationService()
                let fuelService = Container.shared.petrolService()
                
                let preferredPetrolType = fuelService.petrolType
                
                for try await location in locationService.locations {
                    let stations = try await fuelService.getPetrolStations(
                        coordinate: location.coordinate,
                        radius: 20,
                        sorting: .distance,
                        type: preferredPetrolType,
                        shouldReload: true
                    )
                    
                    await MainActor.run {
                        self.fuelStations = stations
                    }
                    break
                }
            } catch {
                print("Error loading fuel stations: \(error.localizedDescription)")
            }
        }
        
    }
    
    private func updateFuelStationSection() {
        
        let openFuelStations = fuelStations.filter({ $0.isOpen })
        
        let openItems = openFuelStations.map({ (item: PetrolStation) -> CPListItem in
            
            let listItem = CPListItem(
                text: "\(item.name)",
                detailText: "\(item.price != nil ? "\(item.price ?? 0.0)" : "?")€ · \(item.distance)",
                image: nil,
                accessoryImage: nil,
                accessoryType: .disclosureIndicator
            )
            
            listItem.handler = { [weak self] (listItem, completion) in
                guard let strongSelf = self else { return }
                strongSelf.showFuelStation(fuelStation: item, completion: completion)
            }
            
            return listItem
        })
        
        let openSection = CPListSection(items: openItems, header: "Tankstellen in Deiner Nähe", sectionIndexTitle: nil)
        
        self.fuelStationsTemplate.updateSections([openSection])
        
    }
    
}

// MARK: - CPTemplateApplicationSceneDelegate -

extension CarPlaySceneDelegate: CPTemplateApplicationSceneDelegate {
    
    public func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didConnect interfaceController: CPInterfaceController) {
        
        self.scene = templateApplicationScene
        
        self.interfaceController = interfaceController
        self.interfaceController?.delegate = self
        
        parkingAreasTemplate.tabImage = UIImage(systemName: "parkingsign.circle")
        fuelStationsTemplate.tabImage = UIImage(systemName: "fuelpump.circle")
        
        let tabBar = CPTabBarTemplate(templates: [parkingAreasTemplate, fuelStationsTemplate])
        tabBar.delegate = self
        self.interfaceController?.setRootTemplate(tabBar, animated: true, completion: {_, _ in })

    }
    
    private func templateApplicationScene(_ templateApplicationScene: CPTemplateApplicationScene, didDisconnect interfaceController: CPInterfaceController) {
        self.interfaceController = nil
    }
    
}

// MARK: - CPTabBarTemplateDelegate -

extension CarPlaySceneDelegate: CPTabBarTemplateDelegate {
    
    public func tabBarTemplate(_ tabBarTemplate: CPTabBarTemplate, didSelect selectedTemplate: CPTemplate) {
        
    }
    
}

// MARK: - CPInterfaceControllerDelegate -

extension CarPlaySceneDelegate: CPInterfaceControllerDelegate {
    
    public func templateWillAppear(_ aTemplate: CPTemplate, animated: Bool) {
        print("templateWillAppear", aTemplate)
        
        if aTemplate == parkingAreasTemplate {
            loadParkingLots()
//            favoriteRadiosListTemplate.updateSections([updateRadiosList(onlyWithFavorites: true)])
        } else if aTemplate == fuelStationsTemplate {
            loadFuelStations()
        }
    }
    
    public func templateDidAppear(_ aTemplate: CPTemplate, animated: Bool) {
        print("templateDidAppear", aTemplate)
    }
    
    public func templateWillDisappear(_ aTemplate: CPTemplate, animated: Bool) {
        print("templateWillDisappear", aTemplate)
    }
    
    public func templateDidDisappear(_ aTemplate: CPTemplate, animated: Bool) {
        print("templateDidDisappear", aTemplate)
    }
    
}
