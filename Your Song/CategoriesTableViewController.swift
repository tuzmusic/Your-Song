//
//  CategoriesTableViewController.swift
//  Song Browser
//
//  Created by Jonathan Tuzman on 3/18/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import UIKit

class CategoriesTableViewController: BrowserTableViewController {
	
	var items = [String]()
	var sortForSubtitle: String? // Not sure if String is right for this. It may need to be a closure or something.
	
	override func viewDidLoad() {
		super.viewDidLoad()
		items = orderedSet(for: category, in: songs)
	}
	
	
	// MARK: - Table view data source
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if searchController.isActive && !searchController.searchBar.text!.isEmpty {
			return filteredItems.count
		}
		return items.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		
		var item = ""
		if searchController.isActive && !searchController.searchBar.text!.isEmpty {
			item = filteredItems[indexPath.row]
		} else {
			item = items[indexPath.row]
		}
		
		//let item = items[indexPath.row]
			cell.textLabel?.text = item
			let predicate = NSPredicate(format: "\(category) like %@", item)
			let songsByArtist = songs.filter { predicate.evaluate(with: $0) }
			cell.detailTextLabel?.text =  songsByArtist.count == 1 ? "1 song" : "\(songsByArtist.count) songs"
		
		return cell
	}
}
