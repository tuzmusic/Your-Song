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
	var allSection = 0
	
	let numbers = [ "0", "1", "2", "3", "4", "5", "6", "7", "8", "9" ]
	let letters = [ "A","B","C","D","E","F","G","H","I","J","K","L","M",
	                "N","O","P","Q","R","S","T","U","V","W","X","Y","Z" ]
	var allKeys: Array<String> { return numbers + letters }

	func getActiveKeys() -> [String] {
		
		activeKeys.removeAll()
		numberKeyCount = 0
		
		if let results = results {
			for key in allKeys {
				if results.objects(with: NSPredicate(format: "sortName BEGINSWITH %@", key)).count > 0 {
					if numbers.contains(key) {
						numberKeyCount += 1
						if !activeKeys.contains("#") {
							activeKeys.append("#")
						}
					} else {
						activeKeys.append(key)
					}
				}
			}
		}
		return activeKeys
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return getActiveKeys().isEmpty ? 1 : activeKeys.count + allSection
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if let results = results, !activeKeys.isEmpty {
			if activeKeys.contains("#"), section == 0 {
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
		if !activeKeys.isEmpty {
			if  indexPath.section > 0 {
				var rowNumber = indexPath.row
				for section in allSection..<indexPath.section {
					rowNumber += self.tableView.numberOfRows(inSection: section)
				}
				return (IndexPath(row: rowNumber, section: 0))
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
		return activeKeys.index(of: title)! + allSection
	}
}
