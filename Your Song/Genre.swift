//
//  Genre.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 3/24/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import Foundation
import RealmSwift

class Genre: BrowserCategory {
	
	var songs = LinkingObjects(fromType: Song.self, property: className().lowercased())
	
	var artists: List<Artist> {
		let list = List<Artist>()
		for song in songs {
			if !self.artists.contains(song.artist) {
				list.append(song.artist)
			}
		}
		return List(list.sorted(byKeyPath: "sortName"))
	}
	
	var decades: List<Decade> {
		let list = List<Decade>()
		for song in songs {
			if !self.decades.contains(song.decade) {
				list.append(song.decade)
			}
		}
		return List(list.sorted(byKeyPath: "sortName"))
	}

}
