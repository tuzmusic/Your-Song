//
//  SignInTableViewController.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 2/1/18.
//  Copyright © 2018 Jonathan Tuzman. All rights reserved.
//

import UIKit
import Realm
import RealmSwift
import GoogleSignIn

class SignInTableViewController: UITableViewController, GIDSignInUIDelegate {
	
	@IBOutlet weak var userNameField: UITextField!
	@IBOutlet weak var passwordField: UITextField!
	@IBOutlet var realmLoginButtons: [UIButton]!
	
	var realm: Realm? {
		didSet {
			toggleRealmButtons(signedIn: (realm == nil ? false : true))
			if realm != nil {
				print("Realm opened. \(self.realm!.objects(Song.self).count) Songs.")
				self.performSegue(withIdentifier: Storyboard.LoginToNewRequestSegue, sender: nil)
			}
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		GIDSignIn.sharedInstance().uiDelegate = self
		
		if let user = SyncUser.current {
			openRealmWithUser(user: user)
		} else {
			toggleRealmButtons(signedIn: false)
		}
		// Uncomment to automatically sign in the user.
		// GIDSignIn.sharedInstance().signInSilently()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let id = segue.identifier {
			switch id {
			case "Register Segue":
				if let vc = segue.destination as? RegisterTableViewController {
					vc.email = userNameField.text
					vc.password = passwordField.text
					vc.delegate = self
				}
			default: break
			}
		}
	}
	
	// MARK: Google sign-in
	
	func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
		// If not already signed in, present sign-in results
		guard let googleUser = GIDSignIn.sharedInstance().currentUser else {
			pr("Error: \(error)"); return
		}
		
		let cred = SyncCredentials.google(token: googleUser.authentication.idToken)
		realmCredLogin(cred: cred)
		
	}
	
	// MARK: Realm-cred sign-in
	
	@IBAction func loginButtonTapped(_ sender: UIButton) {
		
		if SyncUser.current == nil {
			if let username = userNameField.text, let password = passwordField.text {
				let cred = SyncCredentials.usernamePassword(username: username, password: password)
				realmCredLogin(cred: cred)
			}
		}
	}
	
	@IBAction func loginSampleUser(_ sender: UIButton) {
		let creds = ["realm-admin":"", "tuzmusic":"***REMOVED***", "testUser1":"1234"]
		if SyncUser.current == nil {
			if let username = sender.titleLabel?.text, let password = creds[username] {
				let cred = SyncCredentials.usernamePassword(username: username, password: password)
				realmCredLogin(cred: cred)
			}
		}
	}
	
	// YPB Realm login
	
	func realmCredLogin(cred: SyncCredentials) {		
		SyncUser.logIn(with: cred, server: RealmConstants.publicDNS) { (user, error) in
			guard let user = user else {
				pr("SyncUser.login Error: \(error!)"); return
			}
			pr("SyncUser logged in: \(user)")
			self.openRealmWithUser(user: user)
		}
	}
	
	func openRealmWithUser(user: SyncUser) {
		DispatchQueue.main.async {
			// Open the online Realm
			let syncConfig = SyncConfiguration(user: user, realmURL: RealmConstants.realmAddress)
			let realmConfig = Realm.Configuration(syncConfiguration: syncConfig)
			
			do {
				self.realm = try Realm(configuration: realmConfig)
			} catch {
				print("SyncUser logged in but couldn't open realm: Error: \(error)")
			}
		}
	}
	
	@IBAction func logOutAll(_ sender: Any) {
		SyncUser.current?.logOut()
		realm = nil
	}
	
	// MARK: Utility functions
	
	fileprivate func toggleRealmButtons (signedIn: Bool) {
		realmLoginButtons[0].isEnabled = signedIn ? false : true
		realmLoginButtons[1].isEnabled = signedIn ? false : true
		realmLoginButtons[2].isEnabled = signedIn ? true : false
	}
	
	func presentInvalidEmailAlert () {
		let alert = UIAlertController(title: "Invalid email", message: "Please enter a valid email address.", preferredStyle: .alert)
		alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
		present(alert, animated: true, completion: nil)
	}	
}
