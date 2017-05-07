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
	
	var activeKeys = [String]()
	var numberKeyCount = 0
	
	let numbers = [ "0", "1", "2", "3", "4", "5", "6", "7", "8", "9" ]
	let letters = [ "A","B","C","D","E","F","G","H","I","J","K","L","M",
	                "N","O","P","Q","R","S","T","U","V","W","X","Y","Z" ]
	var allKeys: Array<String> { return numbers + letters }

	func getActiveKeys() -> [String] {
		
		activeKeys.removeAll()

		if let results = results {
			
			for key in allKeys {
				if results.objects(with: NSPredicate(format: "sortName BEGINSWITH %@", key)).count > 0 {
					if numbers.contains(String(key.characters.first!)), !activeKeys.contains("#") {
						activeKeys.append("#") // If any items start with a number, put the # sign in the index.
					} else {
						activeKeys.append(key) // If the key is a letter, add it to the keys.
					}
				}
			}
		}
		return activeKeys
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return getActiveKeys().isEmpty ? 1 : activeKeys.count
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		if let results = results, !activeKeys.isEmpty {
			if activeKeys.contains("#"), section == 0 {
				numberKeyCount = 0
				for number in numbers {
					numberKeyCount += Int(results.objects(with: NSPredicate(format: "sortName BEGINSWITH %@", number)).count)
				}
				return numberKeyCount
			} else {
				let startingLetter = activeKeys[section]
				let items = results.objects(with: NSPredicate(format: "sortName BEGINSWITH %@", startingLetter))
				return Int(items.count)
			}
		}
		
		return Int(results?.count ?? 0)
	}
	
	func adjustedIndexPath(for indexPath: IndexPath) -> IndexPath {
		if let results = results {
			if !(activeKeys.contains("#") && indexPath.section == 0) {
				let startingLetter = activeKeys[indexPath.section]
				let items = results.objects(with: NSPredicate(format: "sortName BEGINSWITH[c] %@", startingLetter))
				let object = items[UInt(indexPath.row)]
				return IndexPath(row: Int(results.index(of: object)), section: 0)
			}
		}
		return indexPath
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		return super.tableView(tableView, cellForRowAt: adjustedIndexPath(for: indexPath))
	}
	
	override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
		return activeKeys
	}
	
	override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
		return activeKeys.index(of: title)!
	}
}
