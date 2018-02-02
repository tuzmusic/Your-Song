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

class SignInTableViewController: UITableViewController {
	
	@IBOutlet weak var userNameField: UITextField!
	@IBOutlet weak var passwordField: UITextField!
	
	var realm: Realm? {
		didSet {
			pr("Realm is set. \(self.realm!.objects(Song.self).count) Songs.")
		}
	}
	
	override func viewDidAppear(_ animated: Bool) {
		if let user = SyncUser.current {
			pr("Current user!")
			openRealmWithUser(user: user)
		}
	}
	
	@IBAction func loginButtonTapped(_ sender: Any) {
		
		// add protection for if someone is already logged in
		
		if let username = userNameField.text where !username.isEmpty, let password = passwordField.text where !password.isEmpty {
			realmLogin(username: username, password: password, register: false)
		}
	}
	
	@IBAction func registerButtonTapped(_ sender: Any) {
		if let username = userNameField.text, let password = passwordField.text {
			realmLogin(username: username, password: password, register: true)
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
				print(error)
			}
		}
	}
	
	func realmLogin(username: String, password: String, register: Bool) {
		
		let cred = SyncCredentials.usernamePassword(username: username, password: password, register: register)
		
		SyncUser.logIn(with: cred, server: RealmConstants.publicDNS) {
			(user, error) in
			guard let user = user else {
				print("Error: \(error!)")
				return
			}
			self.openRealmWithUser(user: user)
		}
	}
	
	
	@IBAction func logOutAll(_ sender: Any) {
		for user in SyncUser.all {
			user.value.logOut()
		}
	}
}
