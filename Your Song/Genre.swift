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
	
	var artists = List<Artist>() {
		didSet {
			artists = List(artists.sorted(byKeyPath: "sortName"))
		}
	}
	
	var decades = List<Decade>()

}
