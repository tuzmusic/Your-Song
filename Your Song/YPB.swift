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
	
	static var currentRequest: Request?
	
	static var realmSynced: Realm!
	static var realmLocal = try! Realm()
	static var realm: Realm!
	static var realmConfig: Realm.Configuration!
	
	static var ypbUser: YpbUser!
	
	struct UserInfo {
		var firstName = ""
		var lastName = ""
		var email = ""
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
    }
    
	class func setupRealm() {
		
		SyncUser.logIn(with: RealmConstants.userCred, server: RealmConstants.publicDNS) {
			
			// Log in the user. If not, use local Realm config. If unable, return nil.
			user, error in
			guard let user = user else {
				print("Could not access server. Error:")
				print(error!)
				return
			} // guard else
			
			DispatchQueue.main.async {
				
				// Open the online Realm
				let syncConfig = SyncConfiguration(user: user, realmURL: RealmConstants.realmAddress)
				realmConfig = Realm.Configuration(syncConfiguration: syncConfig)
				
				YPB.realmSynced = try! Realm(configuration: YPB.realmConfig)
				YPB.realm = realmSynced
				NotificationCenter.default.post(name: NSNotification.Name("realm set"), object: nil)
				
			}
		}
    }
	
	class func notifyOf(_ request: Request) {
		
		let content = UNMutableNotificationContent()
		content.title = "New Request!"
		content.body = request.userString + " wants to hear \"" + (request.songObject?.title ?? request.songString) + "\""
		content.setValue("YES", forKeyPath: "shouldAlwaysAlertWhileAppIsForeground")
		
		let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0.1, repeats: false)
		let request = UNNotificationRequest(identifier: "oneSec", content: content, trigger: trigger)
		let center = UNUserNotificationCenter.current()
		center.add(request, withCompletionHandler: nil)
	}
	
	class func addSampleRequest() -> Bool {
		if let realm = YPB.realmSynced {
			let user = YpbUser.user(firstName: "Jonathan", lastName: "Tuzman", email: "tuzmusic@gmail.com", in: realm)
			let request = Request()
			let requestsInRealm = realm.objects(Request.self).count
			request.user = user
			request.songObject = realm.objects(Song.self)[requestsInRealm]
            request.songString = request.songObject!.title
			request.notes = "Sample request #\(requestsInRealm)"
			try! realm.write {
				realm.create(Request.self, value: request, update: false)
			}
			return true
		} else {
			return false
		}
	}
	
	class func manageRealmContents() {
		if YPB.realmLocal.objects(Song.self).isEmpty {
			if !YPB.realmSynced.objects(Song.self).isEmpty {
				YPB.populateLocalRealmFromSyncedRealm()
			} else {
				//SongImporter().importSongs()
				YPB.populateSyncedRealmFromLocalRealm()
			}
		} else {
			// Local realm is all good, so do nothing.
			// TO-DO: Note that this will never UPDATE a non-empty realm!
		}
		YPB.deleteDuplicateCategories(in: YPB.realm)
	}
	
	class func populateLocalRealmFromSyncedRealm() {
		let onlineSongs = YPB.realmSynced.objects(Song.self)
		for song in onlineSongs {
			try! YPB.realmLocal.write {
				_ = Song.createSong(fromObject: song, in: YPB.realmLocal)
			}
		}
	}
	
	class func populateSyncedRealmFromLocalRealm() {
		for song in YPB.realmLocal.objects(Song.self) {
			try! YPB.realmSynced.write {
				_ = Song.createSong(fromObject: song, in: YPB.realmSynced)
			}
		}
	}
	
	class func emptyLocalRealm() {
		try! YPB.realmLocal.write {
			YPB.realmLocal.deleteAll()
		}
	}	
}
