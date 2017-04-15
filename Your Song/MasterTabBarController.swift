//
//  MasterTabBarController.swift
//  Song Browser
//
//  Created by Jonathan Tuzman on 3/17/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import UIKit
import RealmSwift

class MasterTabBarController: UITabBarController {
	
	var songs = [Song]() {
		didSet {
			for vc in self.viewControllers! {
				if let browser = vc as? BrowserTableViewController {
					browser.songs = songs
				}
			}
		}
	}
	
	var usingOnlineRealm = false
	
	let offlineRealm = try! Realm()
	
	var realm: Realm! {
		didSet {
			let songsInRealm = realm.objects(Song.self).sorted(byKeyPath: "title")
			// UserDefaults.standard.set(Array(songsInRealm) as AnyObject, forKey: defaultsKey)
			
			if songsInRealm.isEmpty {
				print("No songs in Realm. Importing songs to offline Realm and switching Realms")
				realm = try! Realm()
				importSongs()
				print("\(songsInRealm.count) songs imported from file into Realm.")
			}
			
			// Store songs from online realm to offline realm.
			/*
			if realm != offlineRealm {
				try! offlineRealm.write {
					songsInRealm.forEach {
						offlineRealm.create(Song.self, value: $0, update: false)
					}
				}
			}
			*/
			
			songs = Array(songsInRealm)
		}
	}
	
	func importSongs() {
		let importer = SongImporter()
		let fileName = "song list 2"
		if let songData = importer.getSongDataFromTSVFile(named: fileName) {
			importer.writeSongsToLocalRealm(songData: songData)
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		setupOnlineRealm()
	}
	
	func setupOnlineRealm() {
		let username = "tuzmusic@gmail.com"
		let password = "***REMOVED***"
		let localHTTP = URL(string:"http://54.208.237.32:9080")!
		
		SyncUser.logIn(with: .usernamePassword(username: username, password: password), server: localHTTP) {
			
			// Log in the user
			user, error in
			guard let user = user else {
				/* print("Could not access server. Using UserDefaults for songs.")
				if let storedSongs = UserDefaults.standard.value(forKey: defaultsKey) as? [Song] {
				self.songs = storedSongs
				} */
				print("Could not access server. Using offline Realm for songs.")
				//self.realm = self.offlineRealm
				self.realm = try! Realm()
				// print("\n\(error!)\n")
				return
			}
			
			DispatchQueue.main.async {
				// Open the online Realm
				let realmAddress = URL(string:"realm://54.208.237.32:9080/YourPianoBar/JonathanTuzman/")!
				let syncConfig = SyncConfiguration (user: user, realmURL: realmAddress)
				let configuration = Realm.Configuration(syncConfiguration: syncConfig)
				
				do {
					self.realm = try Realm(configuration: configuration)
					self.usingOnlineRealm = true
				} catch {
					/* print("Could not access server. Using UserDefaults for songs.")
					if let storedSongs = UserDefaults.standard.value(forKey: defaultsKey) as? [Song] {
					self.songs = storedSongs
					} */
					print("Could not open online Realm. Using offline Realm for songs.")
					self.realm = self.offlineRealm
					//print("\n\(error)\n")
				}
			}
		}
	}
}
