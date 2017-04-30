//
//  BrowserViewController.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 4/30/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import UIKit
import RealmSwift
import RealmSearchViewController

class BrowserViewController: RealmSearchViewController {
	

	override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
		var activeKeys = [String]()
		
		// TO-DO: Doesn't deal with numbers or parentheses yet.
		let allKeys = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
		
		if let results = results {
			let predString = (entityName == "Song" ? "title" : "name") + " BEGINSWITH %@"
			for key in allKeys {
				if results.objects(with: NSPredicate(format: predString, key)).count > 0 {
					activeKeys.append(key)
				}
			}
		}
		return activeKeys
	}
	
}
