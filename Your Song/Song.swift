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
//		print("Song has \(newSong.artists.count) artists, \(newSong.decades.count) decades, \(newSong.genres.count) genres")
//		if let testSong = realm.objects(Song.self).last {
//			print("Test: \(testSong.songDescription) has \(testSong.artists.count) artists, \(testSong.decades.count) decades, \(testSong.genres.count) genres")
//
//		}
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
		for artist in song.artists {
			//print("Current artist: \(artist.name)")
			//print("all artists: \(realm.objects(Artist.self).map {$0.name})")
			if realm.objects(Artist.self).filter("name =[c] %@", artist.name).isEmpty {
				//if !realm.objects(Artist.self).contains(artist) {
				print("Creating \(artist.name)")
				try! realm.write { realm.create(Artist.self, value: artist, update: false) }
			} else {
				print("\(artist.name) already exists")
			}
		}
		//print("Creating \"\(song.songDescription)\"")
		//realm.create(Song.self, value: song, update: false)
		
		newSong.artists = song.artists
		newSong.artist = song.artists.first!  // MARK: Artist created
		
		newSong.songDescription = song.songDescription
		newSong.dateModified = song.dateModified
		newSong.dateAdded = song.dateAdded
		try! realm.write {
			realm.create(Song.self, value: newSong, update: false)
		}
		
		return newSong // MARK: Artist created twice more here!
	}

}
