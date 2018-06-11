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



struct RealmConstants {
	static let address = "your-piano-bar.us1.cloud.realm.io"
	static let authURL = URL(string:"https://\(address)")!
	static let realmURL = URL(string:"realms://\(address)/YourPianoBar/JonathanTuzman/")!
}

class SignInTableViewController: UITableViewController, GIDSignInUIDelegate, RealmDelegate {
	
	@IBOutlet weak var emailField: UITextField!
	@IBOutlet weak var passwordField: UITextField!

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(true)
		emailField.text = ""
		passwordField.text = ""
	}
	
	var spinner = UIActivityIndicatorView()
	var proposedUser = YpbUser()
	
	var realm: Realm?
	var usersToken: NotificationToken?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		if let user = SyncUser.current {
			pr("SyncUser was already logged in: \(user.identity!)")
			proposedUser.id = user.identity!
			openRealmWithUser(user: user)
		} else {
			realm = nil
		}
	}
		
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		spinner.stopAnimating()
		if let vc = segue.destination as? RegisterTableViewController {	// prepare for Register segue
			vc.email = emailField.text
			vc.password = passwordField.text
			vc.loginDelegate = self
		} else if let vc = segue.destination as? CreateRequestTableViewController { // prepare for CreateRequest segue
			usersToken?.invalidate()
            vc.realm = self.realm
		}
	}
	
	// MARK: Realm-cred sign-in
	
	@IBAction func loginButtonTapped(_ sender: UIButton) {
		if SyncUser.current == nil {
			let email = emailField.text!
			let password = passwordField.text!
			
			guard !email.isEmpty && !password.isEmpty else {
				present(UIAlertController.basic(title: nil, message: "Please enter your email address and password."), animated: true)
				return
			}
			
			proposedUser.email = email // to see if we have a user with this EMAIL ADDRESS
			let cred = SyncCredentials.usernamePassword(username: email, password: password)
			realmCredLogin(cred: cred)
		}
	}
	
	// YPB Realm login
	
	func realmCredLogin(cred: SyncCredentials) {	// Should probably rename, since I think this may for all kinds of creds.
		spinner = view.addNewSpinner()
		
		SyncUser.logIn(with: cred, server: RealmConstants.authURL) { [weak self] (user, error) in
			if let syncUser = user {    // can't check YpbUser yet because we're not in the realm, where YpbUsers are
				self?.openRealmWithUser(user: syncUser); pr("SyncUser now logged in: \(syncUser.identity!)")
			} else if let error = error {
				self?.present(UIAlertController.basic(title: "Login failed", message: error.localizedDescription), animated: true); pr("SyncUser.login Error: \(error)")
				self?.spinner.stopAnimating()
			}
		}
	}
	
	fileprivate func openRealmWithUser(user: SyncUser) {
		DispatchQueue.main.async { [weak self] in
			let config = user.configuration(realmURL: RealmConstants.realmURL, fullSynchronization: false, enableSSLValidation: true, urlPrefix: nil)
			self?.realm = try! Realm(configuration: config)
            self?.setupRealm()
		}
	}
	
	fileprivate func setupRealm() {
		guard let realm = realm else { return }
		
		let _ = realm.objects(Song.self).subscribe()	// should ultimately be moved to the prepare(for:) method of CreateRequestVC
		let _ = realm.objects(YpbUser.self).subscribe()
       
		usersToken = realm.objects(YpbUser.self).filter("email = %@", proposedUser.email).observe { [weak self] changes in
            self?.findYpbUser(in: realm)
		}
	}
	
	fileprivate func findYpbUser(in realm: Realm) {
		/* Once we're not dealing with SyncUsers created w/o YpbUsers, I think this is here to see if someone has already been registered as a YpbUser using a different authentication method. The login handler for that method should set the proposedUser.email
		
		// note: I think there is a way to have this happen where the proposedUser is an optional, but for now we check against an initialized YpbUser instead of checking whether it's been set.
		*/
		
		if proposedUser != YpbUser() {  // if any properties of proposedUser have been set
			let existingUser = YpbUser.existingUser(for: proposedUser, in: realm)
			guard existingUser == nil else { // If we find the YpbUser, set as current:
				try! realm.write {
					pr("YpbUser found: \(existingUser!)")
					YpbUser.current = existingUser
					performSegue(withIdentifier: Storyboard.LoginToNewRequestSegue, sender: nil)
				}
				return
			}
			createNewYpbUser(for: proposedUser, in: realm)
		} else {
			pr("proposed user hasn't been modified. WTF?")
		}
	}
	
	fileprivate func createNewYpbUser(for info: YpbUser, in realm: Realm) {
		print("YpbUser not found. Attempting to create new user...") // i.e., SyncUser set, but no YpbUser found. i.e., creating a new YpbUser
		
		guard !proposedUser.firstName.isEmpty || !proposedUser.lastName.isEmpty else { pr("Cannot create user: No name provided/found."); return }
		
		// Once we're not dealing with SyncUsers created w/o YpbUsers, I think this should only ever get called from RegisterVC (and so should maybe reside there)
		let newYpbUser = YpbUser.user(id: SyncUser.current!.identity, email: info.email,
												firstName: info.firstName, lastName: info.lastName)
		try! realm.write {
            print("YpbUser created: \(newYpbUser.firstName) \(newYpbUser.lastName) (\(newYpbUser.email)). Set as YpbUser.current.")
			realm.add(newYpbUser)
			YpbUser.current = newYpbUser
			performSegue(withIdentifier: Storyboard.LoginToNewRequestSegue, sender: nil)
		}
	}
	
	func logOutAll() {
		SyncUser.current?.logOut()
		YpbUser.current = nil
		realm = nil
		proposedUser = YpbUser()
		emailField.text = ""
		passwordField.text = ""
	}
}

extension YpbUser {
	class func existingUser (for proposedUser: YpbUser, in realm: Realm) -> YpbUser? {
		let users = realm.objects(YpbUser.self)

		if let emailUser = users.filter("email = %@", proposedUser.email).first {
			return emailUser
		} else if let idUser = users.filter("id = %@", proposedUser.id).first {
			return idUser
		}
		return nil
	}
}
