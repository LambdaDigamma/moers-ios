//
//  TimetableViewController.swift
//  
//
//  Created by Lennart Fischer on 14.04.23.
//

import UIKit
import Combine
import SwiftUI

public class TimetableViewController: UIHostingController<AnyView> {
    
    private let transmitter: TimetableTransmitter
    
    private var cancellables = Set<AnyCancellable>()
    
    public var onShowEvent: ((Event.ID) -> Void)?
    
    public init() {
        self.transmitter = TimetableTransmitter()
        super.init(rootView: TimetableScreen().environmentObject(transmitter).toAnyView())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupUI()
        self.setupTransmitter()
    }
    
    private func setupUI() {
        
        self.navigationItem.largeTitleDisplayMode = .never
        
    }
    
    private func setupTransmitter() {
        
        self.transmitter.showEvent.sink { (eventID: Event.ID) in
            self.onShowEvent?(eventID)
        }
        .store(in: &cancellables)
        
    }
    
}

//@available(iOS 26.0, *)
//extension MFEventsViewController {
//    
//    private func activateActivity() {
//        
//        let activity = NSUserActivity(activityType: "de.okfn.niederrhein.moers-festival.openNextEvents")
//        
//        let title = String.localized("ShowNextEvents")
//        
//        activity.title = title
//        activity.isEligibleForSearch = true
//        activity.keywords = [String.localized("EventKeyword"), String.localized("MFKeyword")]
//        
//        if #available(iOS 12.0, *) {
//            activity.isEligibleForPrediction = true
//        }
//        
//        userActivity = activity
//        userActivity!.becomeCurrent()
//        
//    }
//    
//    private func setupSearchableContent() {
//        
//        let queue = OperationQueue()
//        
//        queue.addOperation {
//            
//            var searchableItems: [CSSearchableItem] = []
//            
//            for viewModel in self.events {
//                
//                let event = viewModel.model
//                
//                let searchableItemAttributeSet = CSSearchableItemAttributeSet(
//                    itemContentType: UTType.text.identifier
//                )
//                
//                searchableItemAttributeSet.title = event.name
//                searchableItemAttributeSet.contentDescription = event.description
//                //                searchableItemAttributeSet.namedLocation = event.getLocation()?.name ?? String.localized("VenueUnknown") // TODO:
//                //                searchableItemAttributeSet.city = event.getLocation()?.place ?? String.localized("CityUnknown") // TODO:
//                searchableItemAttributeSet.endDate = event.endDate
//                searchableItemAttributeSet.startDate = event.startDate
//                searchableItemAttributeSet.keywords = event.name.components(separatedBy: " ") + (event.description ?? "").components(separatedBy: " ")
//                
//                if let url = event.image {
//                    if let data = try? Data(contentsOf: url) {
//                        searchableItemAttributeSet.thumbnailData = data
//                    }
//                }
//                
//                let searchableItem = CSSearchableItem(uniqueIdentifier: "de.okfn.niederrhein.moers-festival.events.\(event.id)",
//                                                      domainIdentifier: "events",
//                                                      attributeSet: searchableItemAttributeSet)
//                
//                searchableItems.append(searchableItem)
//                
//            }
//            
//            
//            CSSearchableIndex.default().deleteAllSearchableItems { (error) in
//                
//                if let error = error {
//                    print(error.localizedDescription)
//                }
//                
//                CSSearchableIndex.default().indexSearchableItems(searchableItems) { (error) in
//                    if let error = error {
//                        print(error.localizedDescription)
//                    }
//                }
//                
//            }
//            
//        }
//        
//    }
//    
//}
