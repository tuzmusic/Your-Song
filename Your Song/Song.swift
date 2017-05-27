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
	var artists = List<Artist>() {
		didSet {
			artist = artists.first
		}
	}

	dynamic var genre: Genre!
	var genres = List<Genre>(){
		didSet {
			genre = genres.first
		}
	}
	
	dynamic var decade: Decade!
	var decades = List<Decade>() {
		didSet {
			decade = decades.first
		}
	}

	let requests = List<Request>()
	dynamic var dateAdded: Date?
	dynamic var dateModified: Date?
	dynamic var songDescription = ""

	var popularity: Int { return self.requests.count }
	
	typealias Indices = (title: Int, artist: Int?, genre: Int?, year: Int?)
	
	class func createSong (fromComponents songComponents: [String], with indices: Indices, in realm: Realm) -> Song? {
		
		let title = songComponents[indices.title].capitalizedWithOddities()
		
		// MARK: Artists
		var artists = List<Artist>()
		if let artistIndex = indices.artist {
			let itemNames = songComponents[artistIndex]
			let names = itemNames.isEmpty ? ["Unknown"] : itemNames.components(separatedBy: Song.separator)
			artists = BrowserCategory.items(forComponents: names, in: realm)
		}
		
		if let existingSong = realm.objects(Song.self).filter("title like[c] %@ AND artist.name like[c] %@", title, artists.first!.name).first {
			return existingSong
		}
		
		// MARK: Create the new song
		let newSong = Song()
		newSong.title = title
		newSong.artists = artists
		
		newSong.songDescription = title
		for artist in newSong.artists {
			if artist == newSong.artists.first! {
				newSong.songDescription += " - \(artist.name)"
			} else {
				newSong.songDescription += ", \(artist.name)"
			}
		}
		
		// MARK: Decade
		if let yearIndex = indices.year {
			newSong.decades = BrowserCategory.items(forComponents: Decade.decadeNames(for: songComponents[yearIndex]), in: realm)
		}
		
		// MARK: Genre
		if let genreIndex = indices.genre {
			let itemNames = songComponents[genreIndex]
			let names = itemNames.isEmpty ? ["Unknown"] : itemNames.components(separatedBy: Song.separator)
			newSong.genres = BrowserCategory.items(forComponents: names, in: realm)
		}
		
		newSong.dateAdded = Date()

		realm.add(newSong)
		print("Song #\(realm.objects(Song.self).count) added to realm: \(newSong.songDescription)")
		return newSong
	}

	class func createSong (fromObject song: Song, in realm: Realm) -> Song? {
		if let existingSong = realm.objects(Song.self)
			.filter("title like[c] %@ AND artist.name like[c] %@", song.title, song.artist.name).first {
			return existingSong
		}
		
		let newSong = Song()
		let simpleCopyKeyPaths = ["title", "songDescription", "dateAdded", "dateModified"]
		for key in simpleCopyKeyPaths {
			newSong.setValue(song.value(forKey: key), forKey: key)
		}
		
		// KVC implementation for categories, doesn't quite work.
		/* let categoryKeyPaths = ["artists", "decades", "genres"]
		for key in categoryKeyPaths {
			let value = song.value(forKey: key)
			let items = BrowserCategory.items(forObjects: value, in: realm)
			newSong.setValue(items, forKey: key)
		} */
		newSong.artists = BrowserCategory.items(forObjects: song.artists, in: realm)
		newSong.decades = BrowserCategory.items(forObjects: song.decades, in: realm)
		newSong.genres = BrowserCategory.items(forObjects: song.genres, in: realm)
		// notes about duplicates:
		/*
		Even with the new items(fromObjects:in:) implementation, this adds two.
		But it's not an issue with the implementation. It adds it once when setting "artists" and then again when didSet sets "artist".
		However, it only does it when first adding the artist! Meaning, each additional song by the same artist doesn't add it again! (this is correct, of course)
		So, I could do a band-aid fix which is after the realm is populated I can delete all categories that are duplicates. But will this cause problems? Are the songs' "artist" properties assigned to the duplicates?
		*/

		realm.create(Song.self, value: newSong, update: false)

		return newSong
	}
	
	class func createSongOLD (fromObject song: Song, in realm: Realm) -> Song? {

		if let existingSong = realm.objects(Song.self)
			.filter("title like[c] %@ AND artist.name like[c] %@", song.title, song.artist.name).first {
			return existingSong
		}
		
		Song.createCategories(fromObject: song, in: realm)	// This creates one (of each, of course)

		let newSong = Song()
		newSong.title = song.title

		newSong.songDescription = song.songDescription
		newSong.dateModified = song.dateModified
		newSong.dateAdded = song.dateAdded
		//newSong = song
		realm.create(Song.self, value: newSong, update: false)
		
		return newSong
	}
	
	class func createCategories(fromObject song: Song, in realm: Realm) {
		for artist in song.artists {
			if realm.objects(Artist.self).filter("name =[c] %@", artist.name).isEmpty {
				print("Creating \(artist.name)")
				realm.create(Artist.self, value: artist, update: false)
			} else {
				print("\(artist.name) already exists")
			}
		}
		
		for decade in song.decades {
			if realm.objects(Decade.self).filter("name =[c] %@", decade.name).isEmpty {
				print("Creating \(decade.name)")
				realm.create(Decade.self, value: decade, update: false)
			} else {
				print("\(decade.name) already exists")
			}
		}
		
		for genre in song.genres {
			if realm.objects(Genre.self).filter("name =[c] %@", genre.name).isEmpty {
				print("Creating \(genre.name)")
				realm.create(Genre.self, value: genre, update: false)
			} else {
				print("\(genre.name) already exists")
			}
		}
	}

}
