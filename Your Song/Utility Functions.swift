//
//  Utility Functions.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 5/27/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import Foundation
import RealmSwift
import RealmSearchViewController

extension YPB {
	
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

	class func createBloggerBlogFromSongCatalog() {
		
	}
	
	class func writeSongCatalogToTxtFile () {
		
		/*
		func precedeSecondArtistWithComma() {
			for song in YPB.realmLocal.objects(Song.self) {
				var components = song.songDescription.components(separatedBy: " - ")
				if components.count > 2 {
					var newDescription = components[0] + " - " + components[1]
					for i in 2 ..< components.count {
						newDescription += ", " + components[i]
					}
					try! YPB.realmLocal.write {
						song.songDescription = newDescription
					}
				}
			}
		} */
		
		// Assemble the text
		var text = ""
		
		let decades = YPB.realmLocal.objects(Decade.self)
		
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



