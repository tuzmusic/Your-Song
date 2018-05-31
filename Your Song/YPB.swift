//
//  YPB.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 4/21/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import Foundation
import RealmSwift
import Realm
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
	
	class func manageContents(of realm: Realm) {

		if realm.objects(Song.self).isEmpty {
			SongImporter.importSongsTo(realm: realm)
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
	
	struct UserInfo {
		var firstName = ""
		var lastName = ""
		var email = ""
	}
}
