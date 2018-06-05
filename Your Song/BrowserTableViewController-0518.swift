//
//  BrowserTableViewController-0518.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 6/4/18.
//  Copyright © 2018 Jonathan Tuzman. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class BrowserTableViewController_0518: UITableViewController {
	
	var results: Results<BrowserObject>!
	
	var extraSection: Int {
		return basePredicate == nil ? 1 : 0
	}

	var realm: Realm? { didSet { self.refreshSearchResults() } }
	var type: BrowserObject.Type! { didSet { self.refreshSearchResults() } }
	var basePredicate: NSPredicate? { didSet { self.refreshSearchResults() } }
	
	@objc func refreshSearchResults() {
		// this will eventually be where searching affects things
		updateResults()
	}
	
	func updateResults() {
		// TO-DO: RSVC also keeps a notification token on the results, which in this case may not be entirely necessary (yet).
		if let realm = realm, let type = type {
			results = realm.objects(type).sorted(byKeyPath: "sortName")
			tableView.reloadData()
		}
	}
	
	// FOR DEBUGGING!
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		print("Section: \(indexPath.section), adjPath: \(adjPath(for: indexPath))")
		updateResults()
	}
	
	var activeKeys = [String]()
	var numberKeyCount = 0
	
	func getActiveKeys() -> [String] {
		
		let numbers = [ "0", "1", "2", "3", "4", "5", "6", "7", "8", "9" ]
		let letters = [ "A","B","C","D","E","F","G","H","I","J","K","L","M",
							 "N","O","P","Q","R","S","T","U","V","W","X","Y","Z" ]
		var allKeys: Array<String> { return numbers + letters }

		activeKeys.removeAll()
		numberKeyCount = 0
		
		if let results = results {
			for key in allKeys {
				if results.filter(NSPredicate(format: "sortName BEGINSWITH %@", key)).count > 0 {
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
		guard !getActiveKeys().isEmpty else { return 1 }
		return activeKeys.count //+ extraSection
		/*
		basePredicate == nil
		All Songs: Yes - show "browse artists/browse genres" option
		All Artists: Yes - show "All Songs" option
		All Decade: Yes - show "All Artists" (and "All Songs") option
		basePredicate != nil - for simplicity's sake, I'm willing to leave out "All Songs in Decade"
		Artists in Decade: Yes - show "All Songs in Decade" option
		Songs in Decade/Songs by Artist: No - no further level in tree; to browse by artist or genre, go back through navigation
		*/
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if let results = results, !activeKeys.isEmpty {
			if activeKeys[section - extraSection] == "#" {
				return numberKeyCount
			} else {
				let startingLetter = activeKeys[section - extraSection]
				let items = results.filter(NSPredicate(format: "sortName BEGINSWITH %@", startingLetter))
				return items.count
			}
		}
		return results?.count ?? 0
	}
	
	func adjPath(for indexPath: IndexPath) -> IndexPath {
		if !activeKeys.isEmpty {
			if indexPath.section > 0 {
				var rowNumber = indexPath.row
				for section in 1..<indexPath.section {
					rowNumber += self.tableView.numberOfRows(inSection: section)
				}
				return IndexPath(row: rowNumber, section: 0)
			}
		}
		return indexPath
	}

	override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
		return activeKeys
	}
	
	override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
		return activeKeys.index(of: title)! + extraSection
	}
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return activeKeys[section - extraSection]
	}
}
