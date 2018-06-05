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

	var realm: Realm? {
		didSet {
			self.refreshSearchResults()
		}
	}
	var type: BrowserObject.Type! {
		didSet {
			self.refreshSearchResults()
		}
	}
	var basePredicate: NSPredicate? {
		didSet {
			self.refreshSearchResults()
		}
	}
	
	func refreshSearchResults() {
		// this will eventually be where searching affects things
		updateResults()
	}
	
	func updateResults() {
		// TO-DO: RSVC also keeps a notification token on the results, which in this case may not be entirely necessary (yet).
		if let realm = realm, let type = type {
			results = realm.objects(type)
			tableView.reloadData()
		}
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
		return activeKeys.count + (basePredicate != nil ? 1 : 0)
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
			if activeKeys.contains("#"), section == 0 {
				return numberKeyCount
			} else {
				let startingLetter = activeKeys[section]
				let items = results.filter(NSPredicate(format: "sortName BEGINSWITH %@", startingLetter))
				return Int(items.count)
			}
		}
		return Int(results?.count ?? 0)
	}
	
	func adjustedIndexPath(for indexPath: IndexPath) -> IndexPath {
		if !activeKeys.isEmpty {
			if indexPath.section > 0 {
				var rowNumber = indexPath.row
				for section in 1..<indexPath.section {		// this 1 needs to respect whether there's an "all" section!
					rowNumber += self.tableView.numberOfRows(inSection: section)
				}
				return (IndexPath(row: rowNumber, section: 0))
			}
		}
		return indexPath
	}
	
	override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
		return activeKeys
	}
	
	override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
		return activeKeys.index(of: title)! + (basePredicate != nil ? 1 : 0)
	}
}
