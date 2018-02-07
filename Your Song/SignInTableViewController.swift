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
	
	var proposedUser: YpbUser?
	
	var realm: Realm? {
		didSet {
			if let realm = realm {
				print("Realm opened. \(realm.objects(Song.self).count) Songs.")
				
				if let user = realm.objects(YpbUser.self).filter("id = %@", SyncUser.current!.identity!).first {
					
					// TO-DO: If we changed this to check against email (of the proposedUser, or from the SyncUser credentials) inste
					
					try! realm.write { YpbUser.current = user }
					print("YpbUser found: \(user.firstName) \(user.lastName) (\(user.email)). Set as YpbUser.current.")
					
				} else {
					print("YpbUser not found. Creating new user.")
					if let info = proposedUser {
						let newYpbUser = YpbUser.user(id: SyncUser.current!.identity, email: info.email, firstName: info.firstName, lastName: info.lastName)
						try! realm.write {
							realm.add(newYpbUser)
							YpbUser.current = newYpbUser
						}
						if let user = YpbUser.current {
							print("YpbUser created: \(user.firstName) \(user.lastName) (\(user.email)). Set as YpbUser.current.")
						}
					} else {
						// we're using a sample user. loginSampleUser doesn't assign a proposed user, so we end up in this else clause, we don't look for or assign YpbUser.current
					}
				}
				self.performSegue(withIdentifier: Storyboard.LoginToNewRequestSegue, sender: nil)
			}
			toggleRealmButtons(signedIn: (realm == nil ? false : true))
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		GIDSignIn.sharedInstance().uiDelegate = self
		
		// Uncomment to automatically sign in the user.
		// GIDSignIn.sharedInstance().signInSilently()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super .viewWillAppear(true)
		if let user = SyncUser.current {
			openRealmWithUser(user: user)
		} else {
			realm = nil
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let vc = segue.destination as? RegisterTableViewController {
			vc.email = userNameField.text
			vc.password = passwordField.text
			vc.loginDelegate = self
		} else if let vc = segue.destination as? CreateRequestTableViewController {
			vc.realm = self.realm
		}
	}
	
	// MARK: Google sign-in
	
	func sign(inWillDispatch signIn: GIDSignIn!, error: Error!) {
		// If not already signed in, present sign-in results
		guard let googleUser = GIDSignIn.sharedInstance().currentUser else {
			pr("Error: \(error)"); return
		}
		
		if let profile = googleUser.profile {
			proposedUser = YpbUser.user(id: nil, email: profile.email, firstName: profile.givenName, lastName: profile.familyName)
		}
		
		let cred = SyncCredentials.google(token: googleUser.authentication.idToken)
		realmCredLogin(cred: cred)
	}
	
	// MARK: Realm-cred sign-in
	
	@IBAction func loginButtonTapped(_ sender: UIButton) {
		if SyncUser.current == nil {
			if let username = userNameField.text, let password = passwordField.text {
				proposedUser = YpbUser.user(id: nil, email: username, firstName: "", lastName: "") // For the future, we can see if someone with this email already exists, and we can go forward as that YpbUser. This check occurs in the realm.didSet
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
		// Get the user.
		SyncUser.logIn(with: cred, server: RealmConstants.publicDNS) { (user, error) in
			guard let user = user else { pr("SyncUser.login Error: \(error!)"); return }
			
			pr("SyncUser logged in: \(user)")
			
		// Use the user to open the realm.
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
		proposedUser = nil
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
