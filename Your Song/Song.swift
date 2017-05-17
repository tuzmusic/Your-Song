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
	
	class func createSong (from songComponents: [String], with indices: Indices, in realm: Realm) -> Song? {
		
		let title = songComponents[indices.title].capitalizedWithOddities()
		
		var artists = List<Artist>()
		if let artistIndex = indices.artist {
			let itemNames = songComponents[artistIndex]
			let names = itemNames.isEmpty ? ["Unknown"] : itemNames.components(separatedBy: Song.separator)
			artists = BrowserCategory.items(for: names, in: realm)
		}
		
		if let existingSong = realm.objects(Song.self).filter("title like[c] %@ AND artist.name like[c] %@", title, artists.first!.name).first {
			return existingSong
		}
		
		// MARK: Create the new song
		let newSong = Song()
		newSong.title = title
		
		newSong.artists = artists
		//newSong.artist = newSong.artists.first!
		
		newSong.songDescription = title
		newSong.artists.forEach { newSong.songDescription += " - \($0.name)" }

		// MARK: Decade
		if let yearIndex = indices.year {
			newSong.decades = BrowserCategory.items(for: Decade.decadeNames(for: songComponents[yearIndex]), in: realm)
		}
		
		//newSong.decade = newSong.decades.first
		
		if !newSong.decade.artists.contains(newSong.artist) {
			newSong.decade.artists.append(newSong.artist)
		}
		
		// MARK: Genre
		if let genreIndex = indices.genre {
			let itemNames = songComponents[genreIndex]
			let names = itemNames.isEmpty ? ["Unknown"] : itemNames.components(separatedBy: Song.separator)
			newSong.genres = BrowserCategory.items(for: names, in: realm)
		}
	
		//newSong.genre = newSong.genres.first!
		
		if !newSong.genre.artists.contains(newSong.artist) {
			newSong.genre.artists.append(newSong.artist)
		}
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
	
	class func createSong (fromObject song: Song, in realm: Realm) -> Song? {

		if let existingSong = realm.objects(Song.self)
			.filter("title like[c] %@ AND artist.name like[c] %@", song.title, song.artist.name).first {
			return existingSong
		}
		
		var newSong = Song()
		newSong.title = song.title
		for artist in song.artists {
			if realm.objects(Artist.self).filter("name =[c] %@", artist.name).isEmpty {
				print("Creating \(artist.name)")
				try! realm.write {
					realm.create(Artist.self, value: artist, update: false)
				}
			} else {
				print("\(artist.name) already exists")
			}
		}
		
		for decade in song.decades {
			if realm.objects(Decade.self).filter("name =[c] %@", decade.name).isEmpty {
				print("Creating \(decade.name)")
				try! realm.write {
					realm.create(Decade.self, value: decade, update: false)
				}
			} else {
				print("\(decade.name) already exists")
			}
		}
		
		for genre in song.genres {
			if realm.objects(Genre.self).filter("name =[c] %@", genre.name).isEmpty {
				print("Creating \(genre.name)")
				try! realm.write {
					realm.create(Genre.self, value: genre, update: false)
				}
			} else {
				print("\(genre.name) already exists")
			}
		}
		
		newSong.artists = song.artists // Removing this fixes the duplication problem. But then the song has no artists!

		newSong.songDescription = song.songDescription
		newSong.dateModified = song.dateModified
		newSong.dateAdded = song.dateAdded
		//newSong = song
		try! realm.write {
			realm.create(Song.self, value: newSong, update: false)
		}
		
		return newSong // MARK: Artist created twice more here!
	}

}
