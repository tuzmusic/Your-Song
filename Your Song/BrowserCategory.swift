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
	
	static func items<T: BrowserCategory> (at index: Int, of songComponents: [String], in realm: Realm) -> List<T> {
		let components = songComponents[index]
		let names = components.isEmpty ? ["Unknown"] : components.components(separatedBy: Song.separator)
		let items = List<T>()
		for name in names {
			let name = name.capitalizedWithOddities()
			let search = realm.objects(T.self).filter("name like[c] %@", name)
			if let existingItem = search.first {
				items.append(existingItem)
			} else {
				let newItem = T()
				newItem.name = name
				items.append(newItem)
			}
		}
		return items
	}
	
	// Can't figure out how to use LinkingObjects in a superclass yet. This reference to "self" doesn't work.
	// So the LinkingObjects are staying in their subclasses.
	//let songs = LinkingObjects(fromType: Song.self, property: self.objectSchema.className.lowercased())

}
