////
////  Importer.swift
////  Song Importer
////
////  Created by Jonathan Tuzman on 3/16/17.
////  Copyright © 2017 Jonathan Tuzman. All rights reserved.
////
//
//import Foundation
//import RealmSwift
//
//class SongImporter {
//	
//	struct SongHeaderTags {
//		static let title = "song"
//		static let artist = "artist"
//		static let genre = "genre"
//	}
//	
//	var realm: Realm?
//	
//	/* queries, from realm doc 
//		// Query using a predicate string
//		var tanDogs = realm.objects(Dog.self).filter("color = 'tan' AND name BEGINSWITH 'B'")
//
//		// Query using an NSPredicate
//		let predicate = NSPredicate(format: "color = %@ AND name BEGINSWITH %@", "tan", "B")
//		tanDogs = realm.objects(Dog.self).filter(predicate)
//	
//		// Sort tan dogs with names starting with "B" by name
//		let sortedDogs = realm.objects(Dog.self).filter("color = 'tan' AND name BEGINSWITH 'B'").sorted(byKeyPath: "name")
//	
//		// Chaining queries
//		let tanDogs = realm.objects(Dog.self).filter("color = 'tan'")
//		let tanDogsWithBNames = tanDogs.filter("name BEGINSWITH 'B'")
//	
//
//	*/
//	
//	func createSong (from songComponents: [String], headers: [String]) -> Song {
//		
//		let newSong = Song()
//		
//		if headers[0] == SongHeaderTags.title {
//			newSong.title = songComponents[0]
//		}
//		if headers[1] == SongHeaderTags.artist {
//			let artistName = songComponents[1]
//			// check our artist list (our = realm's?) to see if an artist with this name exists
//			// } else {
//			newSong.artist = Artist.newArtist(named: artistName)
//			newSong.artist?.name = songComponents[1]
//		}
//		if headers[2] == SongHeaderTags.genre {
//			if !headers[2].isEmpty {
//				newSong.genres.append(Genre(value: ["name":songComponents[2]]))
//			} else {
//				newSong.genres.append(Genre(value: ["Unknown"]))
//			}
//		}
//		return newSong
//	}
//	
//	func getSongsFromFile (named: String) -> ([Song]) {
//		
//		var songs = [Song]()
//		var headers = [String]()
//		
//		if let path = Bundle.main.path(forResource: named, ofType: "tsv") {
//			if let fullList = try? String(contentsOf: URL(fileURLWithPath: path)).replacingOccurrences(of: "\r", with: "") {
//				var songList = fullList.components(separatedBy: "\n")
//				if let columnHeaders = songList.first?.components(separatedBy: "\t") {
//					headers = columnHeaders
//					songList.removeFirst() // Remove column headers from song list
//					for song in songList {
//						let songComponents = song.components(separatedBy: "\t")
//						
//						// Check for existing song - check the local database (local realm?)
//						// Do I need two separate realms for this?
//						if let realm = realm {
//							if !realm.objects(Song.self).filter("title = songComponents[0] AND artist = songComponents[1]").isEmpty {
//								songs.append(createSong(from: songComponents, headers: headers))
//							}
//						}
//					}
//				}
//			}
//		}
//		return songs
//	}
//	
//	func setupRealm() {
//		let username = "tuzmusic@gmail.com"
//		let password = "***REMOVED***"
//		
//		let localHTTP = "http://54.208.237.32:9080"
//		let realmAddress = "realm://54.208.237.32:9080/~/yourPianoBarSongs/JonathanTuzman/"
//		
//		SyncUser.logIn(with: .usernamePassword(username: username, password: password), server: URL(string: localHTTP)!) {
//			user, error in
//			guard let user = user else {
//				print(String(describing: error!))
//				return
//			}
//			
//			DispatchQueue.main.async {
//				
//				// Open Realm
//				let configuration = Realm.Configuration(
//					syncConfiguration: SyncConfiguration (user: user, realmURL: URL(string: realmAddress)!)
//				)
//				do { self.realm = try Realm(configuration: configuration) } catch { print(error) }
//			}
//		}
//	}
//}
//
