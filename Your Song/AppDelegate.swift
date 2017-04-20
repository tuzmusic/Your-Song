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
	✔︎ 1. Delete all songs in local Realm but 3
	✔︎ 2. Make sure the offline Realm never imports songs
	✔︎ -- When no internet, app should only ever show 3 songs --
	3. Implement update from online realm (when online realm is open, set the config, and refresh results)
		Actually, the song count is printed so quickly that the tableview SHOULD populate correctly.
	
	Try to solve the schema conflict:
	✔︎ 1. Delete entire online AND offline Realms
	✔︎ 2. Run the app. It should recreate and repopulate both realms.
	3. Do all these steps again.
	
	✔︎ (sort of) 4. Also have the console print the number of songs in realm to make sure where in the right place (in case we are but the app isn't showing the right things)
	-- When online, song list should show 3 songs, until realm is opened, then all songs should show --
	
	*** AH HA! It's now saying "3 songs in Online realm" which means it's counting songs from the wrong realm.
	
	Once this works (and we know we're accessing the online realm the way we want to):
	5. Copy songs from online realm to offline realm.
	6. Run without internet, and full song database should show (can also check in realm browser)
	
	*/
	
	func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		// Override point for customization after application launch.
		
		print("Documents folder: \(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])")
		
		// Set the realm configuration
		
		func importSongs() {
			let importer = SongImporter()
			let fileName = "song list 2"
			if let songData = importer.getSongDataFromTSVFile(named: fileName) {
				importer.writeSongsToLocalRealm(songData: songData)
			}
		}
		
		let username = "tuzmusic@gmail.com"
		let password = "***REMOVED***"
		let localHTTP = URL(string:"http://54.208.237.32:9080")!
		
		SyncUser.logIn(with: .usernamePassword(username: username, password: password), server: localHTTP) {
			
			// Log in the user. If not, use local Realm config. If unable, return nil.
			user, error in
			guard let user = user else {
				print("Could not access server. Using local Realm [default configuration].")
				if try! Realm().objects(Song.self).isEmpty {
					importSongs()
				}
				globalConfig = Realm.Configuration.defaultConfiguration
				return
			}
			
			DispatchQueue.main.async {
				// Open the online Realm
				let realmAddress = URL(string:"realm://54.208.237.32:9080/YourPianoBar/~/JonathanTuzman/")!  // THE ~ IS NECESSARY!
				
				// From zero online realms, when everything is run, ~ and no ~ both get populated but never get counted.
				
				let syncConfig = SyncConfiguration (user: user, realmURL: realmAddress)
				let configuration = Realm.Configuration(syncConfiguration: syncConfig)
				globalConfig = configuration
				globalRealm = try! Realm(configuration: globalConfig) // No, this is not asynchronous. It finishes before the next count is printed.
				
				// Even though this shows that the online realm is populated, this error shows up and closes the realm:
				// Bad changeset received: Assertion failed: left().link_target_table_ndx == right().link_target_table_ndx
				// NOTE: This changeset error only happens without the ~ in the realm address.
				
				pr("\(globalRealm.objects(Song.self).count) songs in online Realm (not from didSet)")
				
				// If no songs in online realm, import songs offline realm TO THE ONLINE REALM (shouldn't ever happen once app is released)
				if globalRealm.objects(Song.self).isEmpty {
					let offlineSongs = try! Realm().objects(Song.self)
					
					// If there are no songs in the offline realm, import songs from TSV.
					// Songs are written to the offline Realm from inside importSongs()
					if offlineSongs.isEmpty {
						importSongs() // this method imports songs from a TSV and then writes them to the local realm: Realm()
					}
					globalRealm.beginWrite()
					for song in offlineSongs {
						_ = Song.createSong(from: song, in: globalRealm) // this method creates Song objects and writes them to the globalRealm.
					}
					try! globalRealm.commitWrite()
				}
			}
		}
		
		return true
	}
}

