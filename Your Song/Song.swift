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
	static let separator = " ^^ "
	dynamic var title = "" {
		didSet {
			sortName = title.forSorting()
		}
	}

	dynamic var artist: Artist!
	var artists = List<Artist>()

	dynamic var genre: Genre!
	var genres = List<Genre>()
	
	dynamic var decade: Decade?
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
		let newSong = Song(value: [title])
		newSong.artists = artists
		newSong.artist = newSong.artists.first!
		
		newSong.songDescription = title
		newSong.artists.forEach { newSong.songDescription += " - \($0.name)" }

		if let genreIndex = indices.genre {
			newSong.genres = BrowserCategory.items(at: genreIndex, of: songComponents, in: realm)
		}
		newSong.genre = newSong.genres.first!
		
		if let yearIndex = headers.index(of: SongHeaderTags.year) {
			let yearsList = songComponents[yearIndex]
			let decadeStrings = Decade.decadeNames(for: yearsList)
			newSong.decades = BrowserCategory.items(for: decadeStrings, in: realm)
			/*let yearsList = songComponents[yearIndex]
			let years = yearsList.components(separatedBy: Song.separator)
			for yearString in years {
				if let year = Int(yearString) {
					let decadeName = (year == 0 ? "??" : "'" + String(((year - (year<2000 ? 1900 : 2000)) / 10)) + "0s")
					let decadeSearch = realm.objects(Decade.self).filter("name like[c] %@", decadeName)
					newSong.decades.append(decadeSearch.first ?? Decade(value: [decadeName]))
				}
			}*/
		}
		newSong.decade = newSong.decades.first
		
		var propertiesWithoutHeaders = [String]()
		let propertiesToSkip = ["title", "artist", "genre", "decade", "year"]

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
		
		newSong.dateAdded = Date()
		try! realm.write {
			realm.add(newSong)
			let count = realm.objects(Song.self).count
			print("Song #\(count) added to realm: \(newSong.songDescription)")
		}
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
