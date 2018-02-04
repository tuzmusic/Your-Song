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
	
	fileprivate func toggleRealmLoggedOut() {
		realmLoginButtons[0].isEnabled = true
		realmLoginButtons[1].isEnabled = true
		realmLoginButtons[2].isEnabled = false
	}
	
	fileprivate func toggleRealmLoggedIn() {
		realmLoginButtons[0].isEnabled = false
		realmLoginButtons[1].isEnabled = false
		realmLoginButtons[2].isEnabled = true
	}
	
	var realm: Realm? {
		didSet {
			pr("Realm is set. \(self.realm!.objects(Song.self).count) Songs.")
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		GIDSignIn.sharedInstance().uiDelegate = self
		
		// Uncomment to automatically sign in the user.
		// GIDSignIn.sharedInstance().signInSilently()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		if let user = SyncUser.current {
			toggleRealmLoggedIn()
			pr("Current user! \(user)")
			openRealmWithUser(user: user)
		} else {
			toggleRealmLoggedOut()
		}
	}
	
	// MARK: Google sign-in
	
	func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
		// If not already signed in, present sign-in results
		guard let googleUser = GIDSignIn.sharedInstance().currentUser else {
			pr("Error: \(error)"); return
		}
		
		let cred = SyncCredentials.google(token: googleUser.authentication.idToken)
		realmLogin(cred: cred)
		
	}
	
	// MARK: Realm sign-in
	
	@IBAction func loginButtonTapped(_ sender: UIButton) {
		
		let creds = ["realm-admin":"", "tuzmusic":"***REMOVED***", "testUser1":"1234"]
		
		if SyncUser.current == nil {
			
			if let username = sender.titleLabel?.text, let password = creds[username] {
				let cred = SyncCredentials.usernamePassword(username: username, password: password)
				realmLogin(cred: cred)
			}
			
			else if let username = userNameField.text, let password = passwordField.text {
				let cred = SyncCredentials.usernamePassword(username: username, password: password)
				realmLogin(cred: cred)
			}
		}
	}
	
	@IBAction func registerButtonTapped(_ sender: Any) {
		if SyncUser.current == nil {
			if let username = userNameField.text, let password = passwordField.text {
				let cred = SyncCredentials.usernamePassword(username: username, password: password, register: true)
				realmLogin(cred: cred)
			}
		}
	}
	
	func realmLogin(cred: SyncCredentials) {		
		SyncUser.logIn(with: cred, server: RealmConstants.publicDNS) {
			(user, error) in
			guard let user = user else {
				pr("SyncUser.login Error: \(error!)"); return
			}
			self.toggleRealmLoggedIn()
			pr("Realm user logged in: \(cred)")
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
				// self.performSegue(withIdentifier: Storyboard.LoginToNewRequestSegue, sender: nil)
			} catch {
				print("Open realm: \(error)")
			}
		}
	}
	
	@IBAction func logOutAll(_ sender: Any) {
		for user in SyncUser.all {
			user.value.logOut()
			toggleRealmLoggedOut()
		}
	}
	
	
}
