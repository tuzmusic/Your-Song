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
	dynamic var artist: Artist!
	dynamic var genre: Genre!
	dynamic var year = Int()
	var decade: Int?  // Can't be dynamic. Fix?
	dynamic var decadeString: String {
		return year == 0 ? "??" : "'" + String(((year - (year<2000 ? 1900 : 2000)) / 10)) + "0s"
	}

	var requests: List<Request>?
	dynamic var dateAdded: Date?
	dynamic var dateModified: Date?
	dynamic var songDescription = ""
	
//	override static func primaryKey() -> String? {
//		return "songDescription"
//	}
	
	var popularity: Int { return self.requests?.count ?? 0 }
	
	class func createSong (from song: Song, in realm: Realm) -> Song? {

		if let existingSong = realm.objects(Song.self)
			.filter("title like[c] %@ AND artist.name like[c] %@", song.title, song.artist.name)
			.first {
			return existingSong
		}
		
		let newSong = Song()
		newSong.title = song.title
		let artistName = song.artist.name
		let artistResults = realm.objects(Artist.self).filter("name like[c] %@", artistName)
		newSong.artist = artistResults.isEmpty ? Artist(value: [artistName]) : artistResults.first
		newSong.songDescription = "\(song.title) - \(artistName)"
		
		
		let genreName = song.genre.name
		let genreResults = realm.objects(Genre.self).filter("name =[c] %@", genreName)
		newSong.genre = genreResults.isEmpty ? Genre(value: [genreName]) : genreResults.first
		
		
		newSong.decade = song.decade
		newSong.dateModified = song.dateModified
		newSong.dateAdded = song.dateAdded
		
		realm.create(Song.self, value: newSong, update: false)
		
		return newSong
	}
	
	struct SongHeaderTags {
		static let titleOptions = ["song", "title", "name"]
		static let artist = "artist"
		static let genre = "genre"
	}
	
	class func createSong (from songComponents: [String], in realm: Realm, headers: inout [String]) -> Song? {
		
		// Find the title
		guard let titleHeader = headers.first(where: { SongHeaderTags.titleOptions.contains($0) }),
			let titleIndex = headers.index(of: titleHeader) else
		{
			print("Song could not be created: Title field could not be found.")
			return nil
		}
		
		let title = songComponents[titleIndex].capitalized
		
		var artistName: String = "Unknown Artist"
		if let artistIndex = headers.index(of: SongHeaderTags.artist), !songComponents[artistIndex].isEmpty {
			artistName = songComponents[artistIndex].capitalized
		}
		
		if let existingSong = realm.objects(Song.self).filter("title like[c] %@ AND artist.name like[c] %@", title, artistName).first {
			return existingSong
		}
		
		let newSong = Song(value: [title])

		let artistSearch = realm.objects(Artist.self).filter("name like[c] %@", artistName)
		newSong.artist = artistSearch.isEmpty ? Artist(value: [artistName]) : artistSearch.first
		newSong.songDescription = "\(title) - \(artistName)"

		var genreName: String = "Unknown"
		if let genreIndex = headers.index(of: SongHeaderTags.genre), !songComponents[genreIndex].isEmpty {
			genreName = songComponents[genreIndex].capitalized
		}
		let genreSearch = realm.objects(Genre.self).filter("name =[c] %@", genreName)
		newSong.genre = genreSearch.isEmpty ? Genre(value: [genreName]) : genreSearch.first

		var propertiesWithoutHeaders = [String]()
		let propertiesToSkip = ["title", "artist", "genre"]

		for property in newSong.objectSchema.properties
			where !propertiesToSkip.contains(property.name)
			//where property.type != Object && property.type != List
		{
			if let index = headers.index(of: property.name) {
				newSong.setValue(songComponents[index], forKey: property.name)
			} else {
				propertiesWithoutHeaders.append(property.name)
			}
		}
		//print("Properties not in table: \n \(propertiesWithoutHeaders)")
		
		newSong.dateAdded = Date()
		try! realm.write {
			realm.add(newSong)
			let count = realm.objects(Song.self).count
			print("Song #\(count) added to realm: \(newSong)")
		}
		return newSong
	}
}
