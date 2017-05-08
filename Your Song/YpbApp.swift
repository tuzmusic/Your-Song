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
	
	struct UserInfo {
		var firstName = ""
		var lastName = ""
		var email = ""
	}
	
	class func setupOfflineRealm() {
		ypbRealm = try! Realm()
		try! ypbRealm.write {
			ypbRealm.deleteAll()
		}
		if ypbRealm.objects(Song.self).isEmpty {
			SongImporter().importSongs()
		}
	}
	
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
		
		let localHTTP = URL(string:"http://54.208.237.32:9080")!
		let publicDNS = URL(string:"ec2-54-208-237-32.compute-1.amazonaws.com:9080")!
		
		func tokenString() -> String { return "ewoJImlkZW50aXR5IjogIl9fYXV0aCIsCgkiYWNjZXNzIjogWyJ1cGxvYWQiLCAiZG93bmxvYWQiLCAibWFuYWdlIl0KfQo=:H1qgzZHbRSYdBs0YoJON7ehUZdVDQ8wGKwgYWsQUoupYPycq1cC4PlGZlDZ++Q+gB2ouYcw4bRRri2Z3F5dlWALLWvARgEwB2bDmuOQRcH30IKkdhFp11PnE3StiMn30TDZWWzX31QAyPDvaUyES7/VK/y8CDHmJ8L/UJ/y8w422bmIFTlectnuXBzMRboBZ8JD/PSrXciaPhm9hd/jEEfgYTwB7oyuuch9XrWvPbSrcpWXEr/6j526nuoips1+KTA/h25LzAgCs1+ZeO63RFKi/K3q7y/HkRBB8OWgK9kBQZGIx8eiH4zu7ut4mLGBcs38JnJr4OEvSTSfdZdhGxw==" }
		
		// Paste into terminal to SSH into EC2: 
		/*
		ssh -i /Users/TuzsNewMacBook/Library/Mobile\ Documents/com\~apple\~CloudDocs/Misc\ Stuff\ -\ iCloud\ drive/Programming/IMPORTANT\ Server\ Stuff/KeyPairs/YourPianoBarKeyPair.pem ubuntu@ec2-54-208-237-32.compute-1.amazonaws.com
		*/
		
		let tokenCred = SyncCredentials.accessToken(tokenString(), identity: "admin")
		//let tokenCred = SyncCredentials.accessToken("wrong string", identity: "admin")
		
		// Currently, I'm not actually using a SyncUser. I'm using authentication (Google, FB, YPB, whatever) to create a YpbUser and to allow entry into the next scene of the app.
		
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
				
				// pr("\(YpbApp.ypbRealm.objects(Song.self).count) songs in current Realm")
				
				// If no songs in online realm, import songs offline realm TO THE ONLINE REALM (shouldn't ever happen once app is released)
				
				if YpbApp.ypbRealm.objects(Song.self).isEmpty {
				
					let offlineSongs = try! Realm().objects(Song.self)
					
					// If there are no songs in the offline realm, import songs from TSV.
					// Songs are written to the offline Realm from inside importSongs()
					if offlineSongs.isEmpty {
						SongImporter().importSongs() // this method imports songs from a TSV and then writes them to the local realm: Realm()
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
	/*
	class func forSorting(for name: String) -> String {
		var startingName = name
		var editedName = startingName
		let nameChars = editedName.characters
		
		repeat {
			startingName = editedName
			if editedName.hasPrefix("(") {
				// Delete the parenthetical
				editedName = editedName.substring(from: nameChars.index(after: nameChars.index(of: ")")!))
			} else if !CharacterSet.alphanumerics.contains(editedName.unicodeScalars.first!) {
				// Delete any punctuation, spaces, etc.
				editedName.remove(at: nameChars.index(of: nameChars.first!)!)
			} else if let range = editedName.range(of: "The ") {
				// Delete "The"
				editedName = editedName.replacingOccurrences(of: "The ", with: "", options: [], range: range)
			}
		} while editedName != startingName
		
		return editedName
	}
	*/
}

extension String {
	
	func forSorting() -> String {
		var startingName = self
		var editedName = startingName
		let nameChars = editedName.characters
		
		repeat {
			startingName = editedName
			if editedName.hasPrefix("(") {
				// Delete the parenthetical
				editedName = editedName.substring(from: nameChars.index(after: nameChars.index(of: ")")!))
			} else if !CharacterSet.alphanumerics.contains(editedName.unicodeScalars.first!) {
				// Delete any punctuation, spaces, etc.
				editedName.remove(at: nameChars.index(of: nameChars.first!)!)
			} else if let range = editedName.range(of: "The ") {
				// Delete "The"
				editedName = editedName.replacingOccurrences(of: "The ", with: "", options: [], range: range)
			}
		} while editedName != startingName
		
		return editedName
	}
	
	func capitalizedWithOddities() -> String {
		let chars = self.unicodeScalars
		
		// Account for songs like "ABC"
		var allUppercase = true
		for char in chars {
			if CharacterSet.lowercaseLetters.contains(char) {
				allUppercase = false
				break
			}
		}
		if allUppercase {
			return self
		}
		
		var fullString = ""
		
		let words = self.components(separatedBy: " ")
		for word in words {
			if words.index(of: word)! > 0 {
				fullString += " " // Add a space if it's not the first word.
			}
			if let firstChar = word.unicodeScalars.first {
				if CharacterSet.decimalDigits.contains(firstChar) {
					fullString += word
				} else {
					fullString += word.capitalized
				}
			}
		}
		
		return fullString
	}
}
