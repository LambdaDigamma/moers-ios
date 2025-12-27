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
            "name": String.localized("AuditingEntryName"),
            "lat": String.localized("AuditingEntryLatitude"),
            "lng": String.localized("AuditingEntryLongitude"),
            "tags": String.localized("AuditingEntryTags"),
            "street": String.localized("AuditingEntryStreet"),
            "house_number": String.localized("AuditingEntryHouseNumber"),
            "postcode": String.localized("AuditingEntryPostcode"),
            "place": String.localized("AuditingEntryPlace"),
            "monday": String.localized("AuditingEntryMonday"),
            "tuesday": String.localized("AuditingEntryTuesday"),
            "wednesday": String.localized("AuditingEntryWednesday"),
            "thursday": String.localized("AuditingEntryThursday"),
            "friday": String.localized("AuditingEntryFriday"),
            "saturday": String.localized("AuditingEntrySaturday"),
            "sunday": String.localized("AuditingEntrySunday"),
            "other": String.localized("AuditingEntryOther"),
            "url": String.localized("AuditingEntryWebsite"),
            "phone": String.localized("AuditingEntryPhone"),
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
