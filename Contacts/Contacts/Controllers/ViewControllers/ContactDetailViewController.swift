//
//  ContactDetailViewController.swift
//  Contacts
//
//  Created by Christopher Alegre on 10/18/19.
//  Copyright © 2019 Christopher Alegre. All rights reserved.
//

import UIKit

class ContactDetailViewController: UIViewController, UITextFieldDelegate {
    
    var contact: Contact? {
        didSet {
            self.loadViewIfNeeded()
            self.updateViews()
        }
    }
    
    @IBOutlet weak var contactNameTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.contactNameTextField.delegate = self
        self.phoneNumberTextField.delegate = self
        self.emailTextField.delegate = self
    }
    
    func saveContact(contact: String, email: String?, phone: String?) {
        ContactController.shared.createContact(name: contact, email: email, phone: phone) { (success) in
            if success {
                DispatchQueue.main.async {
                    sleep(5)
                    self.updateViews()
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    func updateContact(contact: Contact) {
        ContactController.shared.updateContacts(contact: contact) { (success) in
            if success {
                DispatchQueue.main.async {
                    self.updateViews()
                    self.navigationController?.popViewController(animated: true)
                }
            }
        }
    }
    
    @IBAction func saveContactButtonTapped(_ sender: UIBarButtonItem) {
        guard let name = contactNameTextField.text, !name.isEmpty,
            let email = emailTextField.text,
            let phone = phoneNumberTextField.text
            else {return}
        
        if let contact = contact {
            contact.contactName = name
            contact.email = email
            contact.phoneNumber = phone
            updateContact(contact: contact)
        } else {
            self.saveContact(contact: name, email: email, phone: phone)
        }
    }
    
    func updateViews() {
        DispatchQueue.main.async {
            if let contact = self.contact {
                self.contactNameTextField.text = contact.contactName
                self.phoneNumberTextField.text = contact.phoneNumber
                self.emailTextField.text = contact.email
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
    
    func dismissView() {
        DispatchQueue.main.async {
            self.dismiss(animated: true, completion: nil)
            self.navigationController?.popViewController(animated: true)
        }
    }
}
