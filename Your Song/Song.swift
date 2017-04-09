//
//  Song.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 3/24/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import Foundation
import RealmSwift

final class Song: Object {
	dynamic var title = ""
	dynamic var artist: Artist?
	dynamic var songDescription = ""
	dynamic var genre: Genre?
	var decade: Int?  // Can't be dynamic. Fix?
	dynamic var decadeString = ""
	var requests: List<Request>?
	dynamic var dateAdded: Date?
	dynamic var dateModified: Date?
	
//	override static func primaryKey() -> String? {
//		return "songDescription"
//	}
	
	var popularity: Int { return self.requests?.count ?? 0 }
	
	class func createSong (from song: Song, in realm: Realm) -> Song? {

		
		if let existingSong = realm.objects(Song.self)
			// Should this be filtering for primary key instead? Or is there a way that Realm uniques with the primay key automatically?
			.filter("title like[c] %@ AND artist.name like[c] %@", song.title, song.artist!.name)
			.first {
			return existingSong
		}
		
		let newSong = Song()
		newSong.title = song.title
		if let artistName = song.artist?.name {
			let results = realm.objects(Artist.self).filter("name like[c] %@", artistName)
			newSong.artist = results.isEmpty ? Artist.newArtist(named: artistName) : results.first
			newSong.songDescription = "\(song.title) - \(artistName)"
		}
		
		if let genreName = song.genre?.name {
			let results = realm.objects(Genre.self).filter("name =[c] %@", genreName)
			newSong.genre = results.isEmpty ? Genre.newGenre(named: genreName) : results.first
		}
		
		newSong.decade = song.decade
		newSong.dateModified = song.dateModified
		newSong.dateAdded = song.dateAdded
		
		realm.create(Song.self, value: newSong, update: false)
		
		return newSong
	}
	
	class func createSong (from songComponents: [String], in realm: Realm, headers: inout [String]) -> Song? {
		
		var headers2 = [String]()
		headers.forEach { headers2.append($0.lowercased()) }
		headers = headers2
		
		// Prep the data
		struct SongHeaderTags {
			static let titleOptions = ["song", "title", "name"]
			static let artist = "artist"
			static let genre = "genre"
			static let decade = "decade"
			static let dateModified = "date modified"
		}
		
		var titleNum: Int? {
			for option in SongHeaderTags.titleOptions {
				for header in headers {
					if header == option {
						return headers.index(of: header)!
					}
				}
			}
			return nil
		}
		
		guard let titleIndex = titleNum else {
			print("Song could not be created: Title field could not be found.")
			return nil
		}
		
		// This is just for checking to see if we already have the song. This artistName won't be used in checking/assigning the artist.
		var artistName = ""
		if let artistIndex = headers.index(of: SongHeaderTags.artist) {
			artistName = songComponents[artistIndex]
		}
		
		// Check to see if we already have this song (by this artist)
		if let existingSong = realm.objects(Song.self)
			.filter("title like[c] %@ AND artist.name like[c] %@", songComponents[titleIndex], artistName)
			.first {
			// print("\"\(songComponents[titleIndex])\" by \(artistName) is already in this database.")
			return existingSong
		}
		
		let newSong = Song()
		newSong.title = songComponents[titleIndex].capitalized
		
		func genericStuffThatDidntWork() {
		
		// Generic function for finding or creating objects for properties
		func objectFor<T: Object> (songProperty: String, type: T.Type, nameForBlankItem: String, createWith newObjectNamed: (String) -> T) -> T? {
			var object = T()
			var name = ""
			if let index = headers.index(of: songProperty) {
				name = songComponents[index].isEmpty ? nameForBlankItem : songComponents[index].capitalized
			} else {
				print("Could not find column for \"\(songProperty)\". Using \"\(nameForBlankItem)\".")
				name = nameForBlankItem
			}
			
			let results = realm.objects(T.self).filter("name like[c] %@", name)
			object = results.isEmpty ? newObjectNamed(name) : results.first!
			return object
		}
		
		//newSong.artist = objectFor(songProperty: SongHeaderTags.artist, type: Artist.self, nameForBlankItem: "Unknown Artist", createWith: Artist.newArtist(named:))
		
		//newSong.genre = objectFor(songProperty: SongHeaderTags.genre, type: Genre.self, nameForBlankItem: "Unknown", createWith: Genre.newGenre(named:))
		}
		
		if let artistIndex = headers.index(of: SongHeaderTags.artist) {
			let artistName = songComponents[artistIndex].isEmpty ? "Unknown Artist" : songComponents[artistIndex].capitalized
			let results = realm.objects(Artist.self).filter("name like[c] %@", artistName)
			newSong.artist = results.isEmpty ? Artist.newArtist(named: artistName) : results.first
		}
		
		if let genreIndex = headers.index(of: SongHeaderTags.genre) {
			let genreName = songComponents[genreIndex].isEmpty ? "Unknown" : songComponents[genreIndex].capitalized
			let results = realm.objects(Genre.self).filter("name =[c] %@", genreName)
			newSong.genre = results.isEmpty ? Genre.newGenre(named: genreName) : results.first
		}
		
		
		// Generic function for creating values for properties
		func valueFor (songProperty: String) -> Any? {
			if let index = headers.index(of: songProperty.capitalized) {
				return songComponents[index] as Any // does this work if the column is blank?
			} else {
				print("Could not find column for \"\(songProperty)\".")
			}
			return nil
		}
		
		newSong.decade = valueFor(songProperty: SongHeaderTags.decade) as? Int
		newSong.dateModified = valueFor(songProperty: SongHeaderTags.dateModified) as? Date
		newSong.dateAdded = Date()

		try! realm.write {
			realm.add(newSong)
			let count = realm.objects(Song.self).count
			print("Song #\(count) added to realm: \(newSong)")
		}
		return newSong
	}
}
