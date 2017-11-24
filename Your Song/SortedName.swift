//
//  SortedName.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 5/3/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import Foundation
import RealmSwift

extension Object {
	
	@objc dynamic var sortedName: String {
		if let propertyName = self.objectSchema.properties.first?.name,
			var startingName = self.value(forKey: propertyName) as? String
		{
			var editedName = startingName
			
			repeat {
				startingName = editedName
				if editedName.hasPrefix("(") && editedName.contains(")") {
					// Delete the parenthetical
					editedName = String(editedName[editedName.index(after: editedName.index(of: ")")!)..<editedName.endIndex])
				} else if !CharacterSet.alphanumerics.contains(editedName.unicodeScalars.first!) {
					// Delete any punctuation, spaces, etc.
					editedName.remove(at: editedName.index(of: editedName.first!)!)
				} else if editedName.hasPrefix("The "), let range = editedName.range(of: "The ") {
					// Delete "The"
					editedName = editedName.replacingOccurrences(of: "The ", with: "", options: [], range: range)
				}
			} while editedName != startingName
			
			return editedName
		}
		return ""
	}
}
