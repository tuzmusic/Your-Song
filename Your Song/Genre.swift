//
//  Genre.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 3/24/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import Foundation
import RealmSwift

final class Genre: Object {
	dynamic var name = ""
	let songs = LinkingObjects(fromType: Song.self, property: "genre")
	
	var artists: [Artist] {
		let songs = Array(self.songs)
		var artists = [Artist]()
		songs.forEach {
			if !artists.contains($0.artist!) {
				artists.append(($0.artist!))
			}
		}
		return artists
	}
}
