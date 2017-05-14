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
		return super.tableView(tableView, cellForRowAt: adjustedIndexPath(for: indexPath))
	}
	
	override func adjustedIndexPath(for indexPath: IndexPath) -> IndexPath {
		if !activeKeys.isEmpty {
			if indexPath.section > 0 {
				var rowNumber = indexPath.row
				for section in 1..<indexPath.section {
					rowNumber += self.tableView.numberOfRows(inSection: section)
				}
				return (IndexPath(row: rowNumber, section: 0))
			}
		}
		return indexPath
	}

	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.section == 0 {
			performSegue(withIdentifier: Storyboard.AllSongsSegue, sender: nil)
		} else {
			super.tableView(tableView, didSelectRowAt: adjustedIndexPath(for: indexPath))
		}
	}
	
	override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
		return activeKeys.index(of: title)! + 1
	}

	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if !activeKeys.isEmpty {
			if section == 0 {
				return "\"All\" (section \(section))"
			} else {
				return activeKeys[section - 1] + " (section #\(section))"
			}
		}
		return nil
	}
}
