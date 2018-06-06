//
//  RealmSetup.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 4/15/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import Foundation
import RealmSwift

class RealmSetup {
	
	var setupConfig: Realm.Configuration!
	
	init() {
		let username = "tuzmusic@gmail.com"
		let password = "samiam"
		let localHTTP = URL(string:"http://54.208.237.32:9080")!
		
		SyncUser.logIn(with: .usernamePassword(username: username, password: password), server: localHTTP) {
			
			// Log in the user. If not, try to return the local Realm. If unable, return nil.
			user, error in
			guard let user = user else {
				print("Could not access server. Using local Realm.")
				self.setupConfig = Realm.Configuration.defaultConfiguration
				return
			}
			
			DispatchQueue.main.async {
				// Open the online Realm
				let realmAddress = URL(string:"realm://54.208.237.32:9080/YourPianoBar/JonathanTuzman/")!
				let syncConfig = SyncConfiguration (user: user, realmURL: realmAddress)
				let configuration = Realm.Configuration(syncConfiguration: syncConfig)
				self.setupConfig = configuration
				
				/* do {
					return try Realm(configuration: configuration)
				} catch {
					print("Could not open online Realm. Using local Realm.")
					return tryLocalRealm()
				} */
			}
		}
	}
}
