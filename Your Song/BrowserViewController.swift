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
	
	var titleName: String? {
		//return results?.firstObject()?.objectSchema.properties.first?.name
		return "sortName"
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		// Called after 1 call to numberOfSections
	}

	let numbers = [ "0", "1", "2", "3", "4", "5", "6", "7", "8", "9" ]
	let letters = [ "A","B","C","D","E","F","G","H","I","J","K","L","M",
	                "N","O","P","Q","R","S","T","U","V","W","X","Y","Z" ]
	
	func getActiveKeys() {
		
		let allKeys = numbers + letters

		if let results = results, let titleName = titleName {
			for key in allKeys {
				if results.objects(with: NSPredicate(format: "\(titleName) BEGINSWITH %@", key)).count > 0 {
					if numbers.contains(String(key.characters.first!)), !activeKeys.contains("#") {
						// If any items start with a number, put the # sign in the index.
						activeKeys.append("#")
					} else {
						// If the key is a letter, add it to the keys.
						activeKeys.append(key)
					}
				}
			}
		}
	}
	var numberKeyCount = 0
}

extension BrowserViewController {
	
	override func numberOfSections(in tableView: UITableView) -> Int {		
		getActiveKeys()
		return activeKeys.isEmpty ? 1 : activeKeys.count
	}

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		if let results = results, let titleName = titleName, !activeKeys.isEmpty {
			if activeKeys.contains("#"), section == 0 {
				for number in numbers {
					numberKeyCount += Int(results.objects(with: NSPredicate(format: "\(titleName) BEGINSWITH %@", number)).count)
				}
				return numberKeyCount
			} else {
				let startingLetter = activeKeys[section]
				let items = results.objects(with: NSPredicate(format: "\(titleName) BEGINSWITH %@", startingLetter))
				return Int(items.count)// + numberKeyCount
			}
		}
		
		return Int(results?.count ?? 0)
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		var adjustedRow = 0
		
		if let results = results, let titleName = titleName, !activeKeys.isEmpty {
			
			if activeKeys.contains("#"), indexPath.section == 0 {
				for num in 0 ..< numberKeyCount {
					return super.tableView(tableView, cellForRowAt: IndexPath(row: num, section: 0))
				}
			}
			let startingLetter = activeKeys[indexPath.section]  // WHEN CLICKING ON "B", WHY IS SECTION 1 AND NOT 2?
			let items = results.objects(with: NSPredicate(format: "\(titleName) BEGINSWITH[c] %@", startingLetter))
			if indexPath.row == 46 {
				print(items.count)
			}
			let object = items[UInt(indexPath.row)]
			adjustedRow = Int(results.index(of: object))// + numberKeyCount
			
			return super.tableView(tableView, cellForRowAt: IndexPath(row: adjustedRow, section: 0))
		}
		
		return super.tableView(tableView, cellForRowAt: indexPath)
	}
	
	override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
		return activeKeys
	}
	
	override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
		return activeKeys.index(of: title)!
	}
}
