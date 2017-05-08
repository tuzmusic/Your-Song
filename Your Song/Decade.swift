//
//  Decade.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 5/8/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import Foundation
import RealmSwift

final class Decade: BrowserCategory {
	
	let songs = LinkingObjects(fromType: Song.self, property: "decade")
	
	var artists: [Artist] {
		var artists = [Artist]()
		self.songs.forEach {
			if !artists.contains($0.artist!) {
				artists.append(($0.artist!))
			}
		}
		return artists
	}
}
