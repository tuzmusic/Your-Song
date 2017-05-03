//
//  SortedName.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 5/3/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import Foundation
import RealmSwift

extension Song {
	var sortName: String {
		if let propertyName = self.objectSchema.properties.first?.name,
			var startingName = self.value(forKey: propertyName) as? String
		{
			var name = startingName
			let nameChars = name.characters
			
			repeat {
				startingName = name
				if name.hasPrefix("(") {
					// Delete the parenthetical
					name = name.substring(from: nameChars.index(after: nameChars.index(of: ")")!))
				} else if !CharacterSet.alphanumerics.contains(name.unicodeScalars.first!) {
					// Delete any punctuation, spaces, etc.
					name.remove(at: nameChars.index(of: nameChars.first!)!)
				} else if let range = name.range(of: "The ") {
					// Delete "The"
					name = name.replacingOccurrences(of: "The ", with: "", options: [], range: range)
				}
			} while name != startingName
			return name
		}
		return ""
	}
}
