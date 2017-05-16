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
//			if let artist = artists.first {
//				self.artist = artist
//			}
////			if artists.count == 1 {
////				self.artist = artists.first!
////			}
		}
	}

	dynamic var genre: Genre!
	var genres = List<Genre>()
	
	dynamic var decade: Decade!
	var decades = List<Decade>()

	let requests = List<Request>()
	dynamic var dateAdded: Date?
	dynamic var dateModified: Date?
	dynamic var songDescription = ""

	var popularity: Int { return self.requests.count }
	
	typealias Indices = (title: Int, artist: Int?, genre: Int?, year: Int?)
	
	class func createSong (from songComponents: [String], with indices: Indices, in realm: Realm) -> Song? {
		
		let title = songComponents[indices.title].capitalizedWithOddities()
		
		var artists = List<Artist>()
		if let artistIndex = indices.artist {
			artists = BrowserCategory.items(from: songComponents[artistIndex], in: realm)
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

		// MARK: Decade
		if let yearIndex = indices.year {
			newSong.decades = BrowserCategory.items(for: Decade.decadeNames(for: songComponents[yearIndex]), in: realm)
		}
		newSong.decade = newSong.decades.first
		// This does NOT support multiple artists (only adds the primary artist to the decade.)
		// And it does NOT support multiple decades! (only adds the primary artist to the song's primary decade)
		if !newSong.decade.artists.contains(newSong.artist) {
			newSong.decade.artists.append(newSong.artist)
		}
		
		// MARK: Genre
		if let genreIndex = indices.genre {
			newSong.genres = BrowserCategory.items(from: songComponents[genreIndex], in: realm)
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
		
		newSong.dateAdded = Date()

		// "Properties without headers" section has been deleted. See older versions.

		realm.add(newSong)
		let count = realm.objects(Song.self).count
		print("Song #\(count) added to realm: \(newSong.songDescription)")
		return newSong
	}
	
	class func createSong (from song: Song, in realm: Realm) -> Song? {
		print("Creating from \"\(song.songDescription)\"")
		if let existingSong = realm.objects(Song.self)
			.filter("title like[c] %@ AND artist.name like[c] %@", song.title, song.artist.name).first {
			return existingSong
		}
		
		let newSong = Song()
		newSong.title = song.title
		realm.beginWrite()
		for artist in song.artists {
//			print("Current artist: \(artist.name)")
//			print("all artists: \(realm.objects(Artist.self).map {$0.name})")
			if realm.objects(Artist.self).filter("name like[c] %@", artist.name).isEmpty {
				print("Creating \(artist.name)")
				//realm.create(Artist.self, value: artist, update: false)
			} else {
				print("\(artist.name) already exists")
			}
		}
		//print("Creating \"\(song.songDescription)\"")
		//realm.create(Song.self, value: song, update: false)

		try! realm.commitWrite()
		
		newSong.artists = song.artists
		newSong.artist = song.artists.first!
		
		newSong.songDescription = song.songDescription
		newSong.dateModified = song.dateModified
		newSong.dateAdded = song.dateAdded
		try! realm.write {
			realm.create(Song.self, value: newSong, update: false)
		}
		
		return newSong
	}

}
