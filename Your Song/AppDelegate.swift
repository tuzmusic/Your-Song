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

