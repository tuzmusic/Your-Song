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
	
	class func typeName() -> String {
		return String(describing: type(of: self))
	}
	
	//var songs2 = LinkingObjects(fromType: Song.self, property: BrowserCategory.typeName().lowercased())
	
	//var songs: LinkingObjects<Song> { return LinkingObjects(fromType: Song.self, property: className.lowercased()) }
	
	static func items<T: BrowserCategory> (for components: [String], in realm: Realm) -> List<T> {
		let items = List<T>()
		let names = components.isEmpty ? ["Unknown"] : components
		for name in names {
			let name = name.capitalizedWithOddities()
			let search = realm.objects(T.self).filter("name like[c] %@", name)
			if search.isEmpty {
				let newItem = T()
				newItem.name = name
				items.append(newItem)
			} else if let existingItem = search.first, !items.contains(existingItem) {
				items.append(existingItem)
			}
		}
		return items
	}
}
