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
	
	var extraRows = [String]()

	var realm: Realm! { didSet { self.refreshSearchResults() } }
	var type: BrowserObject.Type! { didSet { self.refreshSearchResults() } }
	var basePredicate: NSPredicate? { didSet { self.refreshSearchResults() } }
	// RSVC calls refreshResults, which calls searchPredicate, which gets various predicate arguments and /combines/ them with the basePredicate to form a compound predicate
	var sortPath: String = "sortName" { didSet { self.refreshSearchResults() } }
	var sortAscending: Bool = true { didSet { self.refreshSearchResults() } }
	
	@objc func refreshSearchResults() {
		/* RSVC version
		let searchString = searchController.searchBar.text
		let predicate = self.searchPredicate(searchString)
		updateResults(predicate) */
		
		updateResults()
	}
	
	func updateResults() {
		/* RSVC version - the MEAT of it is this call:
		if let results = self.searchResults(self.entityName, inRealm: self.rlmRealm, predicate: predicate, sortPropertyKey: self.sortPropertyKey, sortAscending: self.sortAscending)
		
		followed by a check to isReadOnly (for some reason), and then a notification token on the results, which in this case may not be entirely necessary (yet).
		*/
		
		results = searchResults(type, inRealm: realm, predicate: basePredicate, sortPropertyKey: sortPath, sortAscending: sortAscending)
		tableView.reloadData() // fyi: the 'basic' call to this in RSVC is in the notification handler
	}
	
	func searchResults(_ type: BrowserObject.Type?, inRealm realm: Realm?, predicate: NSPredicate?, sortPropertyKey: String?, sortAscending: Bool) -> Results<BrowserObject>? {
		
		guard let realm = realm, let type = type else { return nil }
		
		var results = realm.objects(type)
		
		if let pred = predicate {
			results = results.filter(pred)
		}
		if let sortPath = sortPropertyKey {
			results = results.sorted(byKeyPath: sortPath, ascending: sortAscending)
		}
		
		return results
		
		// TO-DO: combine basePred and search text (and/or other predicate stuff
		
		/* TO-DO: further generalizing of this would include:
		(the declaration here is currently identical to the declaration in RSVC. Using passed arguments for realm and type rather than using their instance values (which are simply passed here by the calling function) seems a little unnecessary but I'm going by RSVC's example)
		realm and type being not implicitly unwrapped
		sortPath being optional (it's got a default value here because I know what kind of objects I'm dealing with)
		different searching options for developer (see RSVC searchPredicate(text:)
		*/
	}
	
	func diagnostics(indexPath: IndexPath) {
		print("indexPath: \(indexPath.section), adjPath: \(adjPath(for: indexPath))")
		print("rows in '\(activeKeys[indexPath.section])': \(tableView.numberOfRows(inSection: indexPath.section))")
		print("songs starting with '\(activeKeys[indexPath.section])': \(results.filter(NSPredicate(format: "sortName BEGINSWITH %@", activeKeys[indexPath.section])).count)")
	}
	
	// MARK: Table View Controller Data Source
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		guard !getActiveKeys().isEmpty else { return 1 }
		return activeKeys.count + extraSection
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
	
	func extraSection(contains section: Int) -> Bool {
		return extraSection == 1 && section == 0
	}
	
	func tuzSearchController(_ searchCon: BrowserTableViewController_0518, cellForNonHeaderRowAt indexPath: IndexPath) -> UITableViewCell {
		print("you have to override cellForNonHeaderRow")
		return UITableViewCell()
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if extraSection(contains: section) {
			return extraRows.count
		}
		
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
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!

		if extraSection(contains: indexPath.section) {
			cell.textLabel?.text = extraRows[indexPath.row]
			cell.detailTextLabel?.text = nil
		} else {
			return tuzSearchController(self, cellForNonHeaderRowAt: indexPath)
		}
		
		return cell
	}
	
	fileprivate func adjPath(for indexPath: IndexPath) -> IndexPath {
		if !activeKeys.isEmpty {
			if indexPath.section > 0 {
				var rowNumber = indexPath.row
				for section in extraSection..<indexPath.section {
					rowNumber += self.tableView.numberOfRows(inSection: section)
				}
				return IndexPath(row: rowNumber, section: 0)
			}
		}
		return indexPath
	}
	
	func object(at indexPath: IndexPath) -> BrowserObject? {
		return results?[adjPath(for: indexPath).row] ?? nil
	}
	
	// MARK: Section index titles and headers
	
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
