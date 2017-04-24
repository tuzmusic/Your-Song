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
	
	static var ypbUser: YpbUser!
	
	class func setupRealm() {
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
		
		func importSongs() {
			let importer = SongImporter()
			let fileName = "song list 2"
			if let songData = importer.getSongDataFromTSVFile(named: fileName) {
				importer.writeSongsToLocalRealm(songData: songData)
			}
		}
		
		let localHTTP = URL(string:"http://54.208.237.32:9080")!
		let publicDNS = URL(string:"ec2-54-208-237-32.compute-1.amazonaws.com:9080")!
		
		func tokenString() -> String { return "ewoJImlkZW50aXR5IjogIl9fYXV0aCIsCgkiYWNjZXNzIjogWyJ1cGxvYWQiLCAiZG93bmxvYWQiLCAibWFuYWdlIl0KfQo=:H1qgzZHbRSYdBs0YoJON7ehUZdVDQ8wGKwgYWsQUoupYPycq1cC4PlGZlDZ++Q+gB2ouYcw4bRRri2Z3F5dlWALLWvARgEwB2bDmuOQRcH30IKkdhFp11PnE3StiMn30TDZWWzX31QAyPDvaUyES7/VK/y8CDHmJ8L/UJ/y8w422bmIFTlectnuXBzMRboBZ8JD/PSrXciaPhm9hd/jEEfgYTwB7oyuuch9XrWvPbSrcpWXEr/6j526nuoips1+KTA/h25LzAgCs1+ZeO63RFKi/K3q7y/HkRBB8OWgK9kBQZGIx8eiH4zu7ut4mLGBcs38JnJr4OEvSTSfdZdhGxw==" }
		
		let tokenCred = SyncCredentials.accessToken(tokenString(), identity: "admin")
		
		SyncUser.logIn(with: tokenCred, server: publicDNS) {
			
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
				let realmAddress = URL(string:"realm://ec2-54-208-237-32.compute-1.amazonaws.com:9080/YourPianoBar/JonathanTuzman/")!
				let syncConfig = SyncConfiguration (user: user, realmURL: realmAddress)
				let configuration = Realm.Configuration(syncConfiguration: syncConfig)

				YpbApp.ypbRealm = try! Realm(configuration: configuration) // No, this is not asynchronous. It finishes before the next count is printed.
				
				/*
				// Even though this shows that the online realm is populated, this error shows up and closes the realm:
				// Bad changeset received: Assertion failed: left().link_target_table_ndx == right().link_target_table_ndx
				// NOTE: This changeset error only happens without the ~ in the realm address.
				*/ // Changeset error info
				
				pr("\(YpbApp.ypbRealm.objects(Song.self).count) songs in current Realm")
				
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
