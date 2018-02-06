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
		email = textFields[0].text!
		password = textFields[1].text!
		firstName = textFields[2].text!
		lastName = textFields[3].text
		
		let cred = SyncCredentials.usernamePassword(username: email!, password: password!, register: true)
		
		// segue back to the login vc? or just login here? the only question is how to make the code more efficient (i.e., currently, logging in here would mean copying the functions to this VC which is redundant. Put them in YPB? I'm not really using that very much these days... (should be passing realm around, like to this VC from Login VC)
		
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
