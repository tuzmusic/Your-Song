//
//  Category.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 5/8/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import Foundation
import RealmSwift

class BrowserCategory: BrowserObject {
	dynamic var name = "" {
		didSet {
			sortName = name.forSorting()
		}
	}
	
	static func categoryItems<T>(called: String, for songComponents: [String]) -> T {
		let artistList = songComponents[artistIndex]
		let artistNames = artistList.isEmpty ? ["Unknown Artist"] : artistList.components(separatedBy: Song.separator)
		let artists = List<Artist>()
		for artistName in artistNames {
			let artistName = artistName.capitalizedWithOddities()
			let artistSearch = realm.objects(Artist.self).filter("name like[c] %@", artistName)
			if let existingArtist = artistSearch.first {
				artists.append(existingArtist)
			} else {
				let newArtist = Artist()
				newArtist.name = artistName
				artists.append(newArtist)
			}
		}
	}
	
	// Can't figure out how to use LinkingObjects in a superclass yet. This reference to "self" doesn't work.
	// So the LinkingObjects are staying in their subclasses.
	//let songs = LinkingObjects(fromType: Song.self, property: self.objectSchema.className.lowercased())

}
