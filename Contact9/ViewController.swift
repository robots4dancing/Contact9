//
//  ViewController.swift
//  Contact9
//
//  Created by ANI on 3/28/17.
//  Copyright © 2017 ANI. All rights reserved.
//

import UIKit
import Contacts
import ContactsUI

class ViewController: UIViewController, CNContactPickerDelegate, CNContactViewControllerDelegate, UINavigationControllerDelegate {
    
    var contactStore = CNContactStore()
    
    //MARK: - Contact Picker Methods
    
    @IBAction func showContactList(button: UIBarButtonItem) {
        let contactListVC = CNContactPickerViewController()
        contactListVC.delegate = self
        present(contactListVC, animated: true, completion: nil)
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        
        let fullname = CNContactFormatter.string(from: contact, style: .fullName)
        print("Name: \(contact.givenName) \(contact.familyName)...\(fullname)")
        
        for email in contact.emailAddresses {
            let label = CNLabeledValue<NSString>.localizedString(forLabel: email.label!)
            let value =  email.value
            print("Email: (\(label)): \(value)")
        }
        
        for phone in contact.phoneNumbers {
            let label = CNLabeledValue<NSString>.localizedString(forLabel: phone.label!)
            let value = phone.value.stringValue
            print("Phone (\(label)): \(value)")
        }
        
    }
    
    //MARK: - Contact Editor Methods
    
    @IBOutlet var lastNameTextField :UITextField!
    
    @IBAction func showContactEditor(button: UIBarButtonItem) {
        if let lastName = lastNameTextField.text {
            presentContactMatching(lastName: lastName)
        }
    }
    
    func presentContactMatching(lastName: String) {
        let predicate = CNContact.predicateForContacts(matchingName: lastName)
        let keysToFetch = [CNContactViewController.descriptorForRequiredKeys()]
        do {
            let contacts = try contactStore.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
            if let firstContact = contacts.first {
                print("Contact: \(firstContact.givenName)")
            }
        } catch {
            print("error")
        }
    }
    
    func displayContact(contact: CNContact) {
        let contactVC = CNContactViewController(for: contact)
        contactVC.contactStore = contactStore
        contactVC.delegate = self
        let navigationController = UINavigationController(rootViewController: contactVC)
        present(navigationController, animated: true, completion: nil)
    }
    
    func contactViewController(_ viewController: CNContactViewController, didCompleteWith contact: CNContact?) {
        print("Editing Done for :\(contact!.familyName)")
    }

    //MARK: - Authorization Methods
    
    func requestAccessToContactType(type: CNEntityType) {
        contactStore.requestAccess(for: type) { (success, error) in
            if success {
                print("Got access")
            } else {
                print("Didn't get access")
            }
        }
    }
    
    func checkContactAuthorizationStatus(type: CNEntityType) {
        let status = CNContactStore.authorizationStatus(for: type)
        switch status {
        case .authorized:
            print("Authorized")
        case .denied, .restricted:
            print("Didn't get access")
        case .notDetermined:
            requestAccessToContactType(type: type)
        }
    }
    
    //MARK: - Life Cycle Methods

    override func viewDidLoad() {
        super.viewDidLoad()
        checkContactAuthorizationStatus(type: .contacts)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }


}

