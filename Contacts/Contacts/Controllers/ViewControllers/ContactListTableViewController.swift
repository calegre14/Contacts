//
//  ContactListTableViewController.swift
//  Contacts
//
//  Created by Christopher Alegre on 10/18/19.
//  Copyright © 2019 Christopher Alegre. All rights reserved.
//

import UIKit

class ContactListTableViewController: UITableViewController {
        
    override func viewDidLoad() {
        super.viewDidLoad()
        fetchContacts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        fetchContacts()
    }
    
    @objc func fetchContacts() {
        ContactController.shared.fetchAllContacts { (success) in
            if success {
                self.updateViews()
            }
        }
    }
    
    func updateViews() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }

    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ContactController.shared.contacts.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contactCell", for: indexPath)
        let contact = ContactController.shared.contacts[indexPath.row]
        cell.textLabel?.text = contact.contactName
        return cell
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let contactToDelete = ContactController.shared.contacts[indexPath.row]
            guard let index = ContactController.shared.contacts.firstIndex(of: contactToDelete) else {return}
            ContactController.shared.deleteContact(contact: contactToDelete) { (success) in
                if success {
                    ContactController.shared.contacts.remove(at: index)
                    DispatchQueue.main.async {
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                    }
                }
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let updateContact = ContactController.shared.contacts[indexPath.row]
        ContactController.shared.updateContacts(contact: updateContact) { (success) in
            if success {
                self.updateViews()
            }
        }
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toShowContactVC" {
            guard let destinationVC = segue.destination as? ContactDetailViewController,
                let contactIndex = tableView.indexPathForSelectedRow else {return}
            let contact = ContactController.shared.contacts[contactIndex.row]
            destinationVC.contact = contact
        }
    }
}
