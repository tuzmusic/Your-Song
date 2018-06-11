//
//  RegisterTableViewController.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 2/6/18.
//  Copyright © 2018 Jonathan Tuzman. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class RegisterTableViewController: UITableViewController {

	// TO-DO: Spinner
	
	var loginDelegate: SignInTableViewController!
    var spinner = UIActivityIndicatorView()
	var email, password, firstName, lastName: String?
	
	@IBOutlet var textFields: [UITextField]! {
		didSet {
			if let email = email {
				textFields[0].text = email
			}
			if let password = password {
				textFields[1].text = password
			}
		}
	}
	
	@IBAction func registerButtonTapped(_ sender: Any) {
		guard checkForEmptyFields() else {
			let alert = UIAlertController.basic(title: "Whoops!", message: "Please enter a valid email address, password, and first name.")
			present(alert, animated: true)
			return
		}
		spinner = view.addNewSpinner()
		email = textFields[0].text!
		password = textFields[1].text!
		
		loginDelegate.proposedUser = YpbUser.user(id: nil, email: email!,
						    firstName: textFields[2].text!,
						    lastName: textFields[3].text ?? "")
		let cred = SyncCredentials.usernamePassword(username: email!, password: password!, register: true)
		loginDelegate.realmCredLogin(cred: cred)
                spinner.stopAnimating()
	}
	
	fileprivate func checkForEmptyFields () -> Bool {
		for (index, field) in textFields.enumerated() {
			switch index {
			case 0:
				if let valid = field.text?.isValidEmailAddress(), !valid {
					return false
				}
				fallthrough
			case 1,2:
				if field.text == nil || field.text!.isEmpty {
					return false
				}
			default: break
			}
		}
		return true
	}
}
