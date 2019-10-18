//
//  Contact.swift
//  Contacts
//
//  Created by Christopher Alegre on 10/18/19.
//  Copyright © 2019 Christopher Alegre. All rights reserved.
//

import Foundation
import CloudKit

struct ContactKey {
    static let typeKey = "Contact"
    static let contactNameKey = "contactName"
    static let emailKey = "email"
    static let phoneNumberKey = "phoneNumber"
    static let ckRecordIDKey = "ckRecordID"
}

class Contact {
    
    var contactName: String
    var email: String?
    var phoneNumber: String?
    let ckRecordID: CKRecord.ID
    
    init(contactName: String, email: String?, phoneNumber: String?, ckRecordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString)) {
        self.contactName = contactName
        self.email = email
        self.phoneNumber = phoneNumber
        self.ckRecordID = ckRecordID
    }
    
    convenience init?(ckRecord: CKRecord) {
        guard let contactName = ckRecord[ContactKey.contactNameKey] as? String,
            let email = ckRecord[ContactKey.emailKey] as? String,
            let phoneNumber = ckRecord[ContactKey.phoneNumberKey] as? String
            else {return nil}
        
        self.init(contactName: contactName, email: email, phoneNumber: phoneNumber, ckRecordID: ckRecord.recordID)
    }
}

extension CKRecord {
    convenience init(contact: Contact) {
        self.init(recordType: ContactKey.typeKey, recordID: contact.ckRecordID)
        self.setValuesForKeys ([
            ContactKey.contactNameKey : contact.contactName,
            ContactKey.phoneNumberKey : contact.phoneNumber as Any,
            ContactKey.emailKey : contact.email as Any
        ])
    }
}

extension Contact: Equatable {
    static func == (lhs: Contact, rhs: Contact) -> Bool {
        return lhs === rhs
    }
}
