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
	
	var songs = LinkingObjects(fromType: Song.self, property: "genre")
	
	var artists: List<Artist> {
		var artists = Array<Artist>()
		for song in songs {
			if !artists.contains(song.artist) {
				artists.append(song.artist)
			}
		}
		artists.sort { $0.sortName < $1.sortName }
		// because the return statement below no longer works, I'm reconstructing this List manually
		//return List(artists)
		let x = List<Artist>()
		artists.forEach {
			x.append($0)
		}
		return x
	}
	
	var decades: List<Decade> {
		var decades = Array<Decade>()
		for song in songs {
			if !decades.contains(song.decade) {
				decades.append(song.decade)
			}
		}
		decades.sort { $0.sortName < $1.sortName }
		let x = List<Decade>()
		decades.forEach {
			x.append($0)
		}
		return x
		//return List(decades)
	}

}
