//
//  SortableObject.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 5/6/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import Foundation
import RealmSwift

class SortableObject: Object {
	
	var sortedName: String {
		if let propertyName = self.objectSchema.properties.first?.name,
			var startingName = self.value(forKey: propertyName) as? String
		{
			var editedName = startingName
			let nameChars = editedName.characters
			
			repeat {
				startingName = editedName
				if editedName.hasPrefix("(") {
					// Delete the parenthetical
					editedName = editedName.substring(from: nameChars.index(after: nameChars.index(of: ")")!))
				} else if !CharacterSet.alphanumerics.contains(editedName.unicodeScalars.first!) {
					// Delete any punctuation, spaces, etc.
					editedName.remove(at: nameChars.index(of: nameChars.first!)!)
				} else if let range = editedName.range(of: "The ") {
					// Delete "The"
					editedName = editedName.replacingOccurrences(of: "The ", with: "", options: [], range: range)
				}
			} while editedName != startingName
			
			return editedName
		}
		return ""
	}
	
}
