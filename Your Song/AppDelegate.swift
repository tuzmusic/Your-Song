//
//  AppDelegate.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 3/24/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import UIKit
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
	
	var window: UIWindow?
	
	/*

	Realm management stuff:
	1. Delete all songs in local Realm but 3
	2. Make sure the offline Realm never imports songs
	-- When no internet, app should only ever show 3 songs --
	3. Implement update from online realm (when online realm is open, set the config, and refresh results)
	4. Also have the console print the number of songs in realm to make sure where in the right place (in case we are but the app isn't showing the right things)
	-- When online, song list should show 3 songs, until realm is opened, then all songs should show --
	
	*/
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		
		print("Documents folder: \(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])")
		
		// Set the realm configuration
		
		let username = "tuzmusic@gmail.com"
		let password = "***REMOVED***"
		let localHTTP = URL(string:"http://54.208.237.32:9080")!
		
		func importSongs() {
			let importer = SongImporter()
			let fileName = "song list 2"
			if let songData = importer.getSongDataFromTSVFile(named: fileName) {
				importer.writeSongsToLocalRealm(songData: songData)
			}
		}
		
		SyncUser.logIn(with: .usernamePassword(username: username, password: password), server: localHTTP) {
			
			// Log in the user. If not, use local Realm config. If unable, return nil.
			user, error in
			guard let user = user else {
				print("Could not access server. Using local Realm [default configuration].")
				importSongs()
				globalConfig = Realm.Configuration.defaultConfiguration
				return
			}
			
			DispatchQueue.main.async {
				// Open the online Realm
				let realmAddress = URL(string:"realm://54.208.237.32:9080/YourPianoBar/JonathanTuzman/")!
				let syncConfig = SyncConfiguration (user: user, realmURL: realmAddress)
				let configuration = Realm.Configuration(syncConfiguration: syncConfig)
				globalConfig = configuration
				
				globalRealm = try! Realm(configuration: globalConfig)
				if globalRealm.objects(Song.self).isEmpty {
					let offlineSongs = try! Realm().objects(Song.self)
					if offlineSongs.isEmpty {
						importSongs() // populate offline songs
					}
					for song in offlineSongs {
						// We're in the online realm, and it's empty. So now we'll upload the offline songs.
						try! globalRealm.write {
							_ = Song.createSong(from: song, in: globalRealm)
						}
					}
				}
			}
		}
		
		return true
	}
}

