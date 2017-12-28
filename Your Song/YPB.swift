//
//  YPB.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 4/21/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import Foundation
import RealmSwift
import UserNotifications

class YPB {
	
	static var realmSynced: Realm! {
		didSet {
			if realmSynced != nil { usingSyncedRealm = true }
		}
	}
	static var realmLocal: Realm! {
		didSet {
			if realmLocal != nil { usingSyncedRealm = false }
		}
	}
	static var realmConfig: Realm.Configuration!
	static var usingSyncedRealm: Bool!
	
	static var ypbUser: YpbUser!
	
	static var realm: Realm! {
		didSet {
			if realm != nil {
				manageContents(of: realm!)
				NotificationCenter.default.post(name: NSNotification.Name("realm set"), object: nil)
			}
		}
	}

	class func setupRealm() {
		
		// TO-DO: Check for current user, to allow for some offline-first stuff (see question in realm forum)
		SyncUser.logIn(with: RealmConstants.userCred, server: RealmConstants.publicDNS) {
			
			// Log in the user. If not, use local Realm config.
			user, error in
			guard let user = user else {
				print("SyncUser.logIn failed. \r Using Local Realm. \r Error:")
				print(error!)
				YPB.realmLocal = try! Realm()
				YPB.realm = realmLocal
				return
			}
			
			DispatchQueue.main.async {
				// Open the online Realm
				let syncConfig = SyncConfiguration(user: user, realmURL: RealmConstants.realmAddress)
				realmConfig = Realm.Configuration(syncConfiguration: syncConfig)
				
				do {
					YPB.realmSynced = try Realm(configuration: YPB.realmConfig)
					YPB.realm = realmSynced
				} catch {
					print("Setting realm with realmConfig failed. \r Using Local Realm. \r Error:")
					YPB.realmLocal = try! Realm()
					YPB.realm = realmLocal
				}
			}
		}
    }
	
	class func manageContents(of realm: Realm) {

		if realm.objects(Song.self).isEmpty {
			SongImporter().importSongsTo(realm: realm)
			deleteDuplicateCategories(in: realm)
		}
		
		if realm.objects(Request.self).isEmpty {
			YpbUser.createUsers(in: realm)
			realm.beginWrite()
			for _ in 1...40 {
				let req = Request.randomRequest(in: realm)
				realm.create(Request.self, value: req, update: false)
			}
			try! realm.commitWrite()
		}
		
		// If we just populated the synced realm, populate the local realm for next time, using a new reference to the realm (keeping YPB.realmLocal nil)
		if usingSyncedRealm  {
			let localRealm = try! Realm()
			localRealm.beginWrite()

			if localRealm.objects(Song.self).isEmpty {
				let localRealm = try! Realm()
				for song in realm.objects(Song.self) {
					localRealm.create(Song.self, value: song, update: false)
				}
				YPB.deleteDuplicateCategories(in: localRealm)
			}
			
			if localRealm.objects(Request.self).isEmpty {
				for req in realm.objects(Request.self) {
					localRealm.create(Request.self, value: req, update: false)
				}
			}
			try! localRealm.commitWrite()
		}
		
	}
	
	struct RealmConstants {
		static let ec2ip = "54.205.63.24"
		static let ec2ipDash = ec2ip.replacingOccurrences(of: ".", with: "-")
		static let amazonAddress = "ec2-\(ec2ipDash).compute-1.amazonaws.com:9080"
		static let localHTTP = URL(string:"http://" + ec2ip)!
		static let publicDNS = URL(string:"http://" + amazonAddress)!
		static let realmAddress = URL(string:"realm://" + amazonAddress + "/YourPianoBar/JonathanTuzman/")!
		
		static let userCred = SyncCredentials.usernamePassword(
			username: "realm-admin", password: "")
        static let tuzCred = SyncCredentials.usernamePassword(
            username: "tuzmusic", password: "***REMOVED***")

		// NOTE: I've also created a "tuzmusic" user with my standard PW, also an admin. See what happens with this...
	}
	
	struct UserInfo {
		var firstName = ""
		var lastName = ""
		var email = ""
	}
}
