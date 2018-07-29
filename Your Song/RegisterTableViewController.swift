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
	
	@IBOutlet weak var registerButton: UIButton!
	
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
		registerButton.isEnabled = false

		guard allFieldsValid() else {
//			_ = alert(title: "Whoops!", message: "Please enter a valid email address, password, and first name.")
			_ = alert(title: "Whoops!", message: "Please enter a valid email address, password, and first name.", shouldPresent: true) {
				[weak self] in self?.registerButton.isEnabled = true
			}
			return
		}

		email = textFields[0].text!
		guard textFields[1].text! == textFields[2].text! else {
			_ = alert(title: "Whoops!", message: "Password and Confirm Password fields don't match.", shouldPresent: true) {
				[weak self] in self?.registerButton.isEnabled = true
			}
			return
		}
		password = textFields[1].text!
		
		loginDelegate.proposedUser = YpbUser.user(id: nil, email: email!,
																firstName: textFields[3].text!,
																lastName: textFields[4].text ?? "")
		let cred = SyncCredentials.usernamePassword(username: email!, password: password!, register: true)
		
		SyncUser.logIn(with: cred, server: RealmConstants.authURL) { [weak self] (user, error) in
			if let syncUser = user {    // can't check YpbUser yet because we're not in the realm, where YpbUsers are
				self?.loginDelegate.openRealmWithUser(user: syncUser); pr("SyncUser now logged in: \(syncUser.identity!)")
			} else if let error = error {
				_ = self?.alert(title: "Uh-oh.",
									 message: error.localizedDescription == "The provided credentials are invalid or the user does not exist." ? "This email is already registered." : error.localizedDescription)
				{
					pr("SyncUser.login Error: \(error)")
					self?.spinner.stopAnimating()
					self?.registerButton.isEnabled = true
				}
			}
		}
	}
	
	fileprivate func allFieldsValid () -> Bool {
		for (index, field) in textFields.enumerated() {
			switch index {
			case 0:
				if let valid = field.text?.isValidEmailAddress(), !valid {
					return false
				}
				fallthrough
			case 1,2,3:
				if field.text == nil || field.text!.isEmpty {
					return false
				}
			default: break
			}
		}
		return true
	}
}
