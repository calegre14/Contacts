//
//  ContactController.swift
//  Contacts
//
//  Created by Christopher Alegre on 10/18/19.
//  Copyright © 2019 Christopher Alegre. All rights reserved.
//

import Foundation
import CloudKit

class ContactController {
    //SOT
    static let shared = ContactController()
    //Private User DataBase
    let privateDB = CKContainer.default().privateCloudDatabase
    //Contact array
    var contacts: [Contact] = []
    
    //MARK:- Create Contact
    func createContact(name: String, email: String?, phone: String?, completion: @escaping (_ success: Bool) -> Void) {
        let newContact = Contact(contactName: name, email: email, phoneNumber: phone)
        let record = CKRecord(contact: newContact)
        
        self.privateDB.save(record) { (record, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(false)
                return
            }
            guard let record = record,
                let contact = Contact(ckRecord: record) else {
                    completion(false)
                    return
            }
            
            self.contacts.append(contact)
            completion(true)
            print("Created Contact: \(record.recordID.recordName) successfully")
        }
    }
    
    //MARK:- Fetch Contacts
    func fetchAllContacts(completion: @escaping (_ success: Bool) -> Void) {
        
        let predicate = NSPredicate(value: true)
        let query = CKQuery(recordType: ContactKey.typeKey, predicate: predicate)
        privateDB.perform(query, inZoneWith: nil) { (foundRecords, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(false)
                return
            }
            guard let records = foundRecords else {
                completion(false)
                return
            }
            let contacts = records.compactMap({ Contact(ckRecord: $0) })
            self.contacts = contacts
            completion(true)
        }
    }
    
    //MARK:- Update Contacts
    func updateContacts(contact: Contact, completion: @escaping (_ success: Bool) -> Void) {
        let recordToUpdate = CKRecord(contact: contact)
        let operation = CKModifyRecordsOperation(recordsToSave: [recordToUpdate], recordIDsToDelete: nil)
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInitiated
        operation.modifyRecordsCompletionBlock = { records, _, error in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(false)
                return
            }
            guard recordToUpdate == records?.first else {
                print("Uexpected record was updated")
                completion(false)
                return
            }
            print("Updated \(recordToUpdate.recordID) successfully in CloudKit")
            completion(true)
        }
        privateDB.add(operation)
    }
    
    //MARK:- Delete Contact
    func deleteContact(contact: Contact, completion: @escaping (_ success: Bool) -> Void) {
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [contact.ckRecordID])
        operation.qualityOfService = .userInitiated
        operation.modifyRecordsCompletionBlock = { _, recordIDs, error in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(false)
                return
            }
            guard contact.ckRecordID == recordIDs?.first else {
                print("Unexpected record was set to delete")
                completion(false)
                return
            }
            print("Deleted \(contact.ckRecordID) from CloudKit successfully")
            completion(true)
        }
        privateDB.add(operation)
    }
}
