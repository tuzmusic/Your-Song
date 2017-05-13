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
	
	//var songs = LinkingObjects(fromType: Song.self, property: className.lowercased())
	
	static func items<T: BrowserCategory> (at index: Int, of songComponents: [String], in realm: Realm) -> List<T> {
		let components = songComponents[index]
		let items = List<T>()
		let names = components.isEmpty ? ["Unknown"] : components.components(separatedBy: Song.separator)
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
	
	static func items<T: BrowserCategory> (for components: [String], in realm: Realm) -> List<T> {
		let items = List<T>()
		let names = components.isEmpty ? ["Unknown"] : components
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
}
