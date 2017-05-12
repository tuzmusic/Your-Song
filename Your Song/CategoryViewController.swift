//
//  CategoryViewController.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 5/11/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import UIKit

class CategoryViewController: BrowserViewController {
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return super.numberOfSections(in: tableView) + 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return section == 0 ? 1 : super.tableView(tableView, numberOfRowsInSection: section - 1)
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var adjIndex = indexPath
		adjIndex.section -= 1
		return super.tableView(tableView, cellForRowAt: adjustedIndexPath(for: adjIndex))
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		//print("Cell at \(indexPath) says \(tableView.cellForRow(at: indexPath)!.textLabel!.text!) and selects", separator: "", terminator: " ")
		if indexPath.section == 0 {
			performSegue(withIdentifier: Storyboard.AllSongsSegue, sender: nil)
		} else {
			var adjIndex = indexPath
			adjIndex.section -= 1
			super.tableView(tableView, didSelectRowAt: adjustedIndexPath(for: adjIndex))
		}
	}
	
	override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
		return activeKeys.index(of: title)! + 1
	}
}
