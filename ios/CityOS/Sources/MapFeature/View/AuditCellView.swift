//
//  AuditCellView.swift
//  Moers
//
//  Created by GitHub Copilot on 26.12.24.
//

import SwiftUI
import Core

struct AuditCellView: View {
    let audit: Audit
    let lookupTable: [String: String]
    
    init(audit: Audit) {
        self.audit = audit
        self.lookupTable = [
            "name": String(localized: "Name", bundle: .module),
            "lat": String(localized: "Latitude", bundle: .module),
            "lng": String(localized: "Longitude", bundle: .module),
            "tags": String(localized: "Tags", bundle: .module),
            "street": String(localized: "Street", bundle: .module),
            "house_number": String(localized: "House Number", bundle: .module),
            "postcode": String(localized: "Postcode", bundle: .module),
            "place": String(localized: "Place", bundle: .module),
            "monday": String(localized: "Monday (Opening Hours)", bundle: .module),
            "tuesday": String(localized: "Tuesday (Opening Hours)", bundle: .module),
            "wednesday": String(localized: "Mittwoch (Opening Hours)", bundle: .module),
            "thursday": String(localized: "Thursday (Opening Hours)", bundle: .module),
            "friday": String(localized: "Friday (Opening Hours)", bundle: .module),
            "saturday": String(localized: "Saturday (Opening Hours)", bundle: .module),
            "sunday": String(localized: "Sunday (Opening Hours)", bundle: .module),
            "other": String(localized: "Other (Opening Hours)", bundle: .module),
            "url": String(localized: "Websete", bundle: .module),
            "phone": String(localized: "Phone", bundle: .module),
        ]
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("vor " + (audit.updatedAt?.timeAgo() ?? "n/v"))
                .font(.system(size: 12, weight: .semibold))
                .foregroundColor(.primary)
            
            HStack(spacing: 8) {
                if let image = eventImage {
                    Image(uiImage: image)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 16, height: 16)
                }
                
                Text(eventText)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.primary)
            }
            
            if audit.event == .updated {
                Text("Änderungsprotokoll:")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                    .padding(.top, 4)
                
                VStack(spacing: 8) {
                    ForEach(changes, id: \.key) { change in
                        AuditChangeRowView(
                            valueDescription: change.valueDescription,
                            oldValue: change.oldValue,
                            newValue: change.newValue
                        )
                    }
                }
                .padding(.bottom, 8)
            }
        }
    }
    
    private var eventImage: UIImage? {
        switch audit.event {
        case .created:
            return UIImage(named: "changeset_add")
        case .updated:
            return UIImage(named: "changeset_update")
        case .deleted:
            return UIImage(named: "changeset_delete")
        case .restored:
            return UIImage(named: "changeset_add")
        }
    }
    
    private var eventText: String {
        switch audit.event {
        case .created:
            return "Eintrag erstellt"
        case .updated:
            return "Eintrag aktualisiert"
        case .deleted:
            return "Eintrag gelöscht"
        case .restored:
            return "Eintrag widerhergestellt"
        }
    }
    
    private struct AuditChange {
        let key: String
        let valueDescription: String
        let oldValue: String
        let newValue: String
    }
    
    private var changes: [AuditChange] {
        guard audit.event == .updated else { return [] }
        
        return audit.newValues.baseValues.compactMap { change -> AuditChange? in
            let newGenericValue = change.value
            let oldGenericValue = audit.oldValues.baseValues[change.key]
            
            var newValueRepresentation = "n/v"
            if let newGenericValue = newGenericValue {
                switch newGenericValue {
                case .string(let value):
                    newValueRepresentation = value
                case .double(let value):
                    newValueRepresentation = value.format(pattern: "%.2f")
                case .integer(let value):
                    newValueRepresentation = String(value)
                }
            }
            
            var oldValueRepresentation = "n/v"
            if let oldGenericValue = oldGenericValue {
                switch oldGenericValue {
                case .string(let value):
                    oldValueRepresentation = value
                case .double(let value):
                    oldValueRepresentation = value.format(pattern: "%.2f")
                case .integer(let value):
                    oldValueRepresentation = String(value)
                case .none:
                    oldValueRepresentation = ""
                }
            }
            
            let valueDescription = lookupTable[change.key] ?? change.key.uppercased(with: Locale.current)
            
            return AuditChange(
                key: change.key,
                valueDescription: valueDescription,
                oldValue: oldValueRepresentation,
                newValue: newValueRepresentation
            )
        }
    }
}
