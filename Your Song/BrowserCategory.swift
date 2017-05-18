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
	
	func typeName() -> String {
		return String(describing: type(of: self))
	}
	
	//var songs2 = LinkingObjects(fromType: Song.self, property: BrowserCategory.typeName().lowercased())
	//var songs: LinkingObjects<Song> { return LinkingObjects(fromType: Song.self, property: className.lowercased()) }
		
	static func items<T: BrowserCategory> (forComponents components: [String], in realm: Realm) -> List<T> {
		let names = components.isEmpty ? ["Unknown"] : components.map { $0.capitalizedWithOddities() }
		return BrowserCategory.createItems(for: names, in: realm)
	}
	
	static func items<T: BrowserCategory> (forObjects objects: List<T>, in realm: Realm) -> List<T> {
		let names = Array<String>(objects.map({$0.name}))
		return BrowserCategory.createItems(for: names, in: realm)
	}
	
	static func createItems<T: BrowserCategory> (for names: [String], in realm: Realm) -> List<T> {
		let items = List<T>()
		for name in names {
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
