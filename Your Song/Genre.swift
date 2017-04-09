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
	
	override static func primaryKey() -> String? {
		return "name"
	}
	
	static func newGenre(named name: String) -> Genre {
		let newGenre = Genre()
		newGenre.name = name
		return newGenre
	}
}
