//
//  YpbApp.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 4/21/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import Foundation
import RealmSwift

class YpbApp {
	
	static var currentRequest: Request?
	
	static var ypbRealm: Realm!
	
	class func setupRealm() {
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
					SongImporter().importSongs()
				}
				//globalConfig = Realm.Configuration.defaultConfiguration
				return
			}
			
			DispatchQueue.main.async {
				// Open the online Realm
				let realmAddress = URL(string:"realm://54.208.237.32:9080/YourPianoBar/~/JonathanTuzman/")!  // THE ~ IS NECESSARY!
				
				// From zero online realms, when everything is run, ~ and no ~ both get populated but never get counted.
				
				let syncConfig = SyncConfiguration (user: user, realmURL: realmAddress)
				let configuration = Realm.Configuration(syncConfiguration: syncConfig)
				//globalConfig = configuration
				YpbApp.ypbRealm = try! Realm(configuration: configuration) // No, this is not asynchronous. It finishes before the next count is printed.
				
				// Even though this shows that the online realm is populated, this error shows up and closes the realm:
				// Bad changeset received: Assertion failed: left().link_target_table_ndx == right().link_target_table_ndx
				// NOTE: This changeset error only happens without the ~ in the realm address.
				
				pr("\(YpbApp.ypbRealm.objects(Song.self).count) songs in online Realm (not from didSet)")
				
				// If no songs in online realm, import songs offline realm TO THE ONLINE REALM (shouldn't ever happen once app is released)
				if YpbApp.ypbRealm.objects(Song.self).isEmpty {
					let offlineSongs = try! Realm().objects(Song.self)
					
					// If there are no songs in the offline realm, import songs from TSV.
					// Songs are written to the offline Realm from inside importSongs()
					if offlineSongs.isEmpty {
						importSongs() // this method imports songs from a TSV and then writes them to the local realm: Realm()
					}
					YpbApp.ypbRealm.beginWrite()
					for song in offlineSongs {
						_ = Song.createSong(from: song, in: YpbApp.ypbRealm) // this method creates Song objects and writes them to the YpbApp.ypbRealm.
					}
					try! YpbApp.ypbRealm.commitWrite()
				}
			}
		}
	}
}
