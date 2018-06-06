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

extension YpbUser {
	class func existingUser (for user: SyncUser, in realm: Realm) -> YpbUser? {
		let id = user.identity!
		return realm.objects(YpbUser.self).filter("id = %@", id).first
	}
}

struct RealmConstants {
	static let address = "your-piano-bar.us1.cloud.realm.io"
	static let authURL = URL(string:"https://\(address)")!
	static let realmURL = URL(string:"realms://\(address)/YourPianoBar/JonathanTuzman/")!
}

class SignInTableViewController: UITableViewController, GIDSignInUIDelegate, RealmDelegate {
	
	@IBOutlet weak var userNameField: UITextField!
	@IBOutlet weak var passwordField: UITextField!
	@IBOutlet var realmLoginButtons: [UIButton]!
	
	override func viewWillAppear(_ animated: Bool) {
		userNameField.text = ""
		passwordField.text = ""
		super.viewWillAppear(true)
	}
	
	var spinner = UIActivityIndicatorView()
	var proposedUser: YpbUser?
	
	fileprivate func createNewYpbUser(for info: YpbUser, in realm: Realm) {
		let newYpbUser = YpbUser.user(id: SyncUser.current!.identity, email: info.email,
												firstName: info.firstName, lastName: info.lastName)
		try! realm.write {
			realm.add(newYpbUser)
			YpbUser.current = newYpbUser
			pr("YpbUser created: \(newYpbUser.firstName) \(newYpbUser.lastName) (\(newYpbUser.email)). Set as YpbUser.current.")
		}
	}
	
	fileprivate func findYpbUser(in realm: Realm) {
		if let user = YpbUser.existingUser(for: SyncUser.current!, in: realm) { // If we find the YpbUser:
			try! realm.write { YpbUser.current = user	}
		} else {
			pr("YpbUser not found.") // i.e., Realm user found, but not YpbUser. Not sure when this would happen. (Well, it happens when we open an empty realm for some reason)
			if let info = proposedUser {
				createNewYpbUser(for: info, in: realm)
			} else {
				// we're using a sample user. loginSampleUser doesn't assign a proposed user, so we end up in this else clause, we don't look for or assign YpbUser.current
				pr("couldn't find creds for sample user")
			}
		}
	}
	
	var realm: Realm? {
		didSet {
			toggleRealmButtons(signedIn: (realm == nil ? false : true))
			if let realm = realm {
				// findYpbUser(in: realm)
				performSegue(withIdentifier: Storyboard.LoginToNewRequestSegue, sender: nil)
			}
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		GIDSignIn.sharedInstance().uiDelegate = self
		
		if let user = SyncUser.current {
			openRealmWithUser(user: user)
		} else {
			realm = nil
		}
		// Uncomment to automatically sign in the user.
		// GIDSignIn.sharedInstance().signInSilently()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		spinner.stopAnimating()
		if let vc = segue.destination as? RegisterTableViewController {	// prepare for Register segue
			vc.email = userNameField.text
			vc.password = passwordField.text
			vc.loginDelegate = self
		} else if let vc = segue.destination as? CreateRequestTableViewController { // prepare for CreateRequest segue
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
		
		let cred = SyncCredentials.google(token: googleUser.authentication.idToken)	// This is what shouldn't work yet, right?
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
		let creds = ["realm-admin":"", "testUser1":"1234"]
		
		if SyncUser.current == nil {
			if let username = sender.titleLabel?.text {
				if let password = creds[username] {
					let cred = SyncCredentials.usernamePassword(username: username, password: password)
					realmCredLogin(cred: cred)
				} else {
					let nicknameCred = SyncCredentials.nickname(username)
					realmCredLogin(cred: nicknameCred)
				}
			}
		}
	}
	
	// YPB Realm login
	
	func realmCredLogin(cred: SyncCredentials) {	// Should probably rename, since I think this is for all kinds of creds.
		
		spinner = view.addNewSpinner()
		
		// Get the user.
		SyncUser.logIn(with: cred, server: RealmConstants.authURL) { (user, error) in
			guard let user = user else {
				self.present(UIAlertController.basic(title: "Uh-Oh", message: "SyncUser.login Error: \(error!)"), animated: true)
				pr(error as Any)
				self.spinner.stopAnimating()
				// TO-DO: Handle login failure
				// pr("SyncUser.login Error: \(error!)")
				return
			}
			pr("SyncUser logged in: \(user)")
			
			self.openRealmWithUser(user: user)
		}
	}
	
	fileprivate func openRealmWithUser(user: SyncUser) {
			DispatchQueue.main.async {
				let syncConfig = SyncConfiguration(user: user, realmURL: RealmConstants.realmURL)
				let realmConfig = Realm.Configuration(syncConfiguration: syncConfig)
				
				do {	// Open the online Realm
					self.realm = try Realm(configuration: realmConfig)
				} catch {
					let message = "SyncUser logged in but couldn't open realm: Error: \(error)"
					self.present(UIAlertController.basic(title: "Uh-Oh", message: message), animated: true)
					pr(message)
				}
			}
	}
	
	@IBAction func logOutAll() {
		SyncUser.current?.logOut()
		realm = nil
		proposedUser = nil
		userNameField.text = ""
		passwordField.text = ""
	}

}
