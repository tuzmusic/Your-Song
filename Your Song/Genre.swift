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
		var artists = Array<Artist>()
		for song in songs {
			if !artists.contains(song.artist) {
				artists.append(song.artist)
			}
		}
		artists.sort { $0.sortName < $1.sortName }
		return List(artists)
	}
	
	var decades: List<Decade> {
		var decades = Array<Decade>()
		for song in songs {
			if !decades.contains(song.decade) {
				decades.append(song.decade)
			}
		}
		decades.sort { $0.sortName < $1.sortName }
		return List(decades)
	}

}
