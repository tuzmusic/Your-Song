//
//  SectionIndexTitlesForRealmSearch.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 4/29/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import Foundation
import RealmSwift
import RealmSearchViewController

extension RealmSearchViewController {

	func indexTitles(type: Object.Type) -> [String] {
		var activeKeys = [String]()
		let allKeys = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z","#"]
		let allNames = (realm.objects(type).map {
			
			$0.value(forKey: $0.objectSchema.properties.first!.name) as! String }).sorted()
		for name in allNames {
			let firstLetter = String(name.characters.first!)
			if allKeys.contains(firstLetter) && !activeKeys.contains(firstLetter) {
				activeKeys.append(firstLetter)
			}
		}
		return activeKeys
	}
}
