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
		return results?.firstObject()?.objectSchema.properties.first?.name
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		getActiveKeys()
	}
	
	func getActiveKeys() {
		
		// TO-DO: Doesn't deal with numbers or parentheses yet.
		let allKeys = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
		
		if let results = results, let titleName = titleName {
			for key in allKeys {
				if results.objects(with: NSPredicate(format: "\(titleName) BEGINSWITH %@", key)).count > 0 {
					activeKeys.append(key)
					
				}
			}
		}
	}
}

extension BrowserViewController {
		
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		var adjustedRow = 0
		
		if let results = results, let titleName = titleName, !activeKeys.isEmpty {
			let startingLetter = activeKeys[indexPath.section]
			let items = results.objects(with: NSPredicate(format: "\(titleName) BEGINSWITH %@", startingLetter))
			let object = items[UInt(indexPath.row)]
			adjustedRow = Int(results.index(of: object))
			
			return super.tableView(tableView, cellForRowAt: IndexPath(row: adjustedRow, section: 0))
		}
		
		return UITableViewCell()
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return activeKeys.isEmpty ? 1 : activeKeys.count
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if let results = results, let titleName = titleName, !activeKeys.isEmpty {
			let startingLetter = activeKeys[section]
			let items = results.objects(with: NSPredicate(format: "\(titleName) BEGINSWITH %@", startingLetter))
			return Int(items.count)
		}
		
		return 0
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return activeKeys.isEmpty ? nil : activeKeys[section]
	}
	
	override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
		
		// TO-DO: Doesn't deal with numbers or parentheses yet. Which means that all the other section header stuff doesn't either.
		let allKeys = ["A","B","C","D","E","F","G","H","I","J","K","L","M","N","O","P","Q","R","S","T","U","V","W","X","Y","Z"]
		
		if let results = results, let titleName = titleName {
			for key in allKeys {
				if results.objects(with: NSPredicate(format: "\(titleName) BEGINSWITH %@", key)).count > 0 {
					activeKeys.append(key)
				}
			}
		}
		return activeKeys
	}
	
	override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
		return index
	}
}
