//
//  Song.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 3/24/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import Foundation
import RealmSwift

final class Song: BrowserObject {
	dynamic var title = "" {
		didSet {
			sortName = title.forSorting()
		}
	}

	static let separator = " ^^ "

	dynamic var artist: Artist!
	var artists = List<Artist>()

	dynamic var genre: Genre!
	var genres = List<Genre>()
	
	dynamic var decade: Decade!
	var decades = List<Decade>()

	let requests = List<Request>()
	dynamic var dateAdded: Date?
	dynamic var dateModified: Date?
	dynamic var songDescription = ""

	var popularity: Int { return self.requests.count }
	
	class func createSong (from songComponents: [String], in realm: Realm, headers: inout [String]) -> Song? {
		struct SongHeaderTags {
			static let titleOptions = ["song", "title", "name"]
			static let artist = "artist"
			static let genre = "genre"
			static let year = "year"
		}
		
		func getHeaderIndices() -> (title: Int?, artist: Int?, genre: Int?, year: Int?) {
			struct SongHeaderTags {
				static let titleOptions = ["song", "title", "name"]
				static let artist = "artist"
				static let genre = "genre"
				static let year = "year"
			}
			var titleIndex: Int?
			if let titleHeader = headers.first(where: { SongHeaderTags.titleOptions.contains($0) }) {
				titleIndex = headers.index(of: titleHeader)
			}
			
			let artistIndex = headers.index(of: SongHeaderTags.artist)
			let genreIndex = headers.index(of: SongHeaderTags.genre)
			let yearIndex = headers.index(of: SongHeaderTags.year)
			return (titleIndex, artistIndex, genreIndex, yearIndex)
		}
		
		let indices = getHeaderIndices()
		
		guard let titleIndex = indices.title else {
			print("Song could not be created: Title field could not be found.")
			return nil
		}
		
		let title = songComponents[titleIndex].capitalizedWithOddities()
		
		// Get all the MULTIPLE ARTISTS. Store them in artistObjects list, to quickly assign them to the new song if/when we get there.
		var artists = List<Artist>()
		if let artistIndex = indices.artist {
			artists = BrowserCategory.items(at: artistIndex, of: songComponents, in: realm)
		}
		if let existingSong = realm.objects(Song.self).filter("title like[c] %@ AND artist.name like[c] %@", title, artists.first!.name).first {
			return existingSong
		}
		
		// MARK: Create the new song
		let newSong = Song()
		newSong.title = title
		newSong.artists = artists
		newSong.artist = newSong.artists.first!
		
		newSong.songDescription = title
		newSong.artists.forEach { newSong.songDescription += " - \($0.name)" }

		if let yearIndex = headers.index(of: SongHeaderTags.year) {
			let yearsList = songComponents[yearIndex]
			let decadeStrings = Decade.decadeNames(for: yearsList)
			newSong.decades = BrowserCategory.items(for: decadeStrings, in: realm)
		}
		newSong.decade = newSong.decades.first
		// This does NOT support multiple artists (only adds the primary artist to the decade.)
		// And it does NOT support multiple decades! (only adds the primary artist to the song's primary decade)
		if !newSong.decade.artists.contains(newSong.artist) {
			newSong.decade.artists.append(newSong.artist)
		}
		newSong.dateAdded = Date()
		
		if let genreIndex = indices.genre {
			newSong.genres = BrowserCategory.items(at: genreIndex, of: songComponents, in: realm)
		}
		newSong.genre = newSong.genres.first!
		// This does NOT support multiple artists (only adds the primary artist to the genre.)
		// And it does NOT support multiple genres! (only adds the primary artist to the song's primary genre)
		if !newSong.genre.artists.contains(newSong.artist) {
			newSong.genre.artists.append(newSong.artist)
		}
		// This also does not support multiples
		if !newSong.genre.decades.contains(newSong.decade) {
			newSong.genre.decades.append(newSong.decade)
		}
		

		var propertiesWithoutHeaders = [String]()
		let propertiesToSkip = ["title", "artist", "genre", "decade", "year"]

		// This is actually superfluous at this point (all pertinent properties are covered above)
		for property in newSong.objectSchema.properties
			where !propertiesToSkip.contains(property.name)
		{
			if let index = headers.index(of: property.name) {
				newSong.setValue(songComponents[index], forKey: property.name)
			} else {
				propertiesWithoutHeaders.append(property.name)
			}
		}
		//print("Properties not in table: \n \(propertiesWithoutHeaders)")
		
		//try! realm.write {
			realm.add(newSong)
			let count = realm.objects(Song.self).count
			print("Song #\(count) added to realm: \(newSong.songDescription)")
			//}
		return newSong
	}
	
	class func createSong (from song: Song, in realm: Realm) -> Song? {
		
		if let existingSong = realm.objects(Song.self)
			.filter("title like[c] %@ AND artist.name like[c] %@", song.title, song.artist.name)
			.first {
			return existingSong
		}
		
		let newSong = Song(value: [song.title])
		let artistName = song.artist.name
		//let artistResults = realm.objects(Artist.self).filter("name like[c] %@", artistName)
		//newSong.artist = artistResults.isEmpty ? Artist(value: [artistName]) : artistResults.first
		newSong.songDescription = "\(song.title) - \(artistName)"
		
		let genreName = song.genre.name
		let genreResults = realm.objects(Genre.self).filter("name =[c] %@", genreName)
		newSong.genre = genreResults.isEmpty ? Genre(value: [genreName]) : genreResults.first
		
		newSong.dateModified = song.dateModified
		newSong.dateAdded = song.dateAdded
		
		realm.create(Song.self, value: newSong, update: false)
		
		return newSong
	}

}
