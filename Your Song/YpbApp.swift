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
	
	static var realmSynced: Realm!
	static var realmLocal = try! Realm()
	
	static var ypbUser: YpbUser!
	
	struct UserInfo {
		var firstName = ""
		var lastName = ""
		var email = ""
	}
	
	class func setupOfflineRealm() {
		//try! YpbApp.realmLocal { YpbApp.realmLocal() }

		if YpbApp.realmLocal.objects(Song.self).isEmpty {
			SongImporter().importSongs()
		}
	}
	

	class func populateLocalRealmFromSyncedRealm() {
		let onlineSongs = YpbApp.realmSynced.objects(Song.self)
		for song in onlineSongs {
			try! YpbApp.realmLocal.write {
				_ = Song.createSong(fromObject: song, in: YpbApp.realmLocal)
			}
		}
	}
	
	class func emptyLocalRealm() {
		try! YpbApp.realmLocal.write { YpbApp.realmLocal.deleteAll() }
	}
	
	class func setupRealm() {
		
		struct RealmConstants {
			
			static let localHTTP = URL(string:"http://54.208.237.32:9080")!
			static let publicDNS = URL(string:"http://ec2-54-208-237-32.compute-1.amazonaws.com:9080")!
			static let realmAddress = URL(string:"realm://ec2-54-208-237-32.compute-1.amazonaws.com:9080/YourPianoBar/JonathanTuzman/")!
			
			static func tokenString() -> String { return "ewoJImlkZW50aXR5IjogIl9fYXV0aCIsCgkiYWNjZXNzIjogWyJ1cGxvYWQiLCAiZG93bmxvYWQiLCAibWFuYWdlIl0KfQo=:H1qgzZHbRSYdBs0YoJON7ehUZdVDQ8wGKwgYWsQUoupYPycq1cC4PlGZlDZ++Q+gB2ouYcw4bRRri2Z3F5dlWALLWvARgEwB2bDmuOQRcH30IKkdhFp11PnE3StiMn30TDZWWzX31QAyPDvaUyES7/VK/y8CDHmJ8L/UJ/y8w422bmIFTlectnuXBzMRboBZ8JD/PSrXciaPhm9hd/jEEfgYTwB7oyuuch9XrWvPbSrcpWXEr/6j526nuoips1+KTA/h25LzAgCs1+ZeO63RFKi/K3q7y/HkRBB8OWgK9kBQZGIx8eiH4zu7ut4mLGBcs38JnJr4OEvSTSfdZdhGxw==" }
			
			static let userCred = SyncCredentials.usernamePassword(username: "tuzmusic@gmail.com", password: "***REMOVED***")
			static let tokenCred = SyncCredentials.accessToken(RealmConstants.tokenString(), identity: "admin")
			//static let tokenCred = SyncCredentials.accessToken("wrong string", identity: "admin")
			
			// Paste into terminal to SSH into EC2:
			/*
			ssh -i /Users/TuzsNewMacBook/Library/Mobile\ Documents/com\~apple\~CloudDocs/Misc\ Stuff\ -\ iCloud\ drive/Programming/IMPORTANT\ Server\ Stuff/KeyPairs/YourPianoBarKeyPair.pem ubuntu@ec2-54-208-237-32.compute-1.amazonaws.com
			*/
			
		}
		
		SyncUser.logIn(with: RealmConstants.userCred, server: RealmConstants.publicDNS) {
			
			// Log in the user. If not, use local Realm config. If unable, return nil.
			user, error in
			guard let user = user else {
				print("Could not access server. Using local Realm [default configuration].")
				if YpbApp.realmLocal.objects(Song.self).isEmpty {
					SongImporter().importSongs()
				}
				return
			}
			
			DispatchQueue.main.async {
				
				// Open the online Realm
				let syncConfig = SyncConfiguration (user: user, realmURL: RealmConstants.realmAddress)
				let configuration = Realm.Configuration(syncConfiguration: syncConfig)
				
				YpbApp.realmSynced = try! Realm(configuration: configuration)
				
				/*
				try! YpbApp.realmSynced.write {
					YpbApp.realmSynced.deleteAll()
				}
				try! YpbApp.realmLocal.write {
					YpbApp.realmLocal.deleteAll()
				}
				*/
				if YpbApp.realmLocal.objects(Song.self).isEmpty {
					if YpbApp.realmSynced.objects(Song.self).isEmpty {
						// this isn't quite right... or at least it should be named something else
						YpbApp.populateSyncedRealmFromLocalRealm()
					}
					YpbApp.populateLocalRealmFromSyncedRealm()
				}
				YpbApp.deleteDuplicateCategories(in: YpbApp.realmLocal)
			}
		}
	}

	class func deleteDuplicateCategories (in realm: Realm) {
		
		let allArtists = realm.objects(Artist.self)
		for artist in allArtists {
			let search = allArtists.filter("name = %@", artist.name)
			if search.count > 1 {
				if artist.songs.isEmpty {
					print("Deleting duplicate with no songs: \(artist.name)")
					try! realm.write {
						realm.delete(artist)
					}
				}
			}
		}
		
		let allGenres = realm.objects(Genre.self)
		for genre in allGenres {
			let search = allGenres.filter("name = %@", genre.name)
			if search.count > 1 {
				if genre.songs.isEmpty {
					print("Deleting duplicate with no songs: \(genre.name)")
					try! realm.write {
						realm.delete(genre)
					}
				}
			}
		}
		
		let allDecades = realm.objects(Decade.self)
		for decade in allDecades {
			let search = allDecades.filter("name = %@", decade.name)
			if search.count > 1 {
				if decade.songs.isEmpty {
					print("Deleting duplicate with no songs: \(decade.name)")
					try! realm.write {
						realm.delete(decade)
					}
				}
			}
		}
		
		// Attempt to genericize this that I can't get to work.
		func deleteDuplicates<T: BrowserCategory>(of type: T, in realm: Realm) {
			let allItems = realm.objects(T.self)
			for item in allItems {
				let search = allItems.filter("name = %@", item.name)
				if search.count > 1 {
					print("Found duplicate: \(item.name)")
					//if item.songs.isEmpty {		this is the line that doesn't work
						print("Deleting duplicate with no songs: \(item.name)")
						try! realm.write {
							realm.delete(item)
						}
					//}
				}
			}
		}
	}

	class func populateSyncedRealmFromLocalRealm() {
		let offlineSongs = YpbApp.realmLocal.objects(Song.self)
		if offlineSongs.isEmpty {
			SongImporter().importSongs()
		}
		
		for song in offlineSongs {
			try! YpbApp.realmSynced.write {
				_ = Song.createSong(fromObject: song, in: YpbApp.realmSynced)
			}
		}
	}
	
	class func writeSongCatalogToFile () {

		func precedeSecondArtistWithComma() {
			for song in YpbApp.realmLocal.objects(Song.self) {
				var components = song.songDescription.components(separatedBy: " - ")
				if components.count > 2 {
					var newDescription = components[0] + " - " + components[1]
					for i in 2 ..< components.count {
						newDescription += ", " + components[i]
					}
					try! YpbApp.realmLocal.write {
						song.songDescription = newDescription
					}
				}
			}
		}		
		
		// Assemble the text
		var text = ""
		
		let decades = YpbApp.realmLocal.objects(Decade.self)

		for decade in decades {
			var songsArray = [Song]()
			for song in decade.songs {
				songsArray.append(song)
			}
			songsArray.sort { $0.songDescription < $1.songDescription }
			text += "\n" + decade.name + "\n"
			for song in songsArray {
				text += song.songDescription + " / "
			}
		}
		
		let fileName = "songCatalog.txt" //this is the file. we will write to and read from it
		if let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first {
			let path = dir.appendingPathComponent(fileName)
			do {
				try text.write(to: path, atomically: false, encoding: String.Encoding.utf8)
			}
			catch {
				print("Couldn't write file")
			}
		}
	}
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
		
		// Still doesn't deal with stuff like "McFerrin." Should probably just capitalize the source data correctly!
		if self.uppercased() == self { return self }
		
		var fullString = ""
		let words = self.components(separatedBy: " ")
		for word in words {
			if words.index(of: word)! > 0 {
				fullString += " " // Add a space if it's not the first word.
			}
			
			if let firstChar = word.unicodeScalars.first {
				// If it starts with a number, don't capitalize it.
				if CharacterSet.decimalDigits.contains(firstChar) {
					fullString += word
				} else if word == word.uppercased() {
					fullString += word
				} else {
					fullString += word.capitalized
				}
			}
		}
		
		if fullString.hasSuffix("S") {
			fullString = String(fullString.characters.dropLast()) + "s"
		}
		
		return fullString
	}
}
