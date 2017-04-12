//
//  BrowserTableViewController.swift
//  Song Browser
//
//  Created by Jonathan Tuzman on 3/17/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import UIKit

class BrowserTableViewController: UITableViewController, UISearchResultsUpdating {
	
	var songs = [Song]() {
		didSet {
			tableView.reloadData()
		}
	}
	var category = String()
	
	func orderedSet(for tag: String, in songs: [Song]) -> [String] {
		let items = Set<String>()
		//songs.forEach { items.insert($0[tag]!) }
		return items.sorted { $0.localizedCaseInsensitiveCompare($1) == ComparisonResult.orderedAscending }
	}
	
	// Implementing search in the Browser superclass:
	
	override func viewDidLoad() {
		super.viewDidLoad()
		addSearchController()
		
		// fix the going black issue with a tab bar delegate method?
	}
	
	let searchController = SearchControllerWithoutCancel(searchResultsController: nil)
	var filteredSongs = [Song]()
	var filteredItems = [String]()
	
	func addSearchController() {
		searchController.searchResultsUpdater = self
		
		searchController.dimsBackgroundDuringPresentation = false
		searchController.hidesNavigationBarDuringPresentation = false
		
		searchController.searchBar.autocapitalizationType = .none
		searchController.searchBar.searchBarStyle = .minimal
		searchController.searchBar.tintColor = UIColor.black
		
		self.definesPresentationContext = true
		
		tableView.tableHeaderView = searchController.searchBar
	}
	
	func filterContentFor(searchText: String, scope: String = "All") {
		
		// This has not been updated for songs as realm objects, and will crash if the search bar is accessed.
		
		let predicate = NSPredicate(format: "\(category) contains [c] %@", searchText)
		filteredSongs = songs.filter { predicate.evaluate(with: $0) }
		filteredItems = orderedSet(for: category, in: filteredSongs)
		tableView.reloadData()
	}
	
	func updateSearchResults(for searchController: UISearchController) {
		filterContentFor(searchText: searchController.searchBar.text!)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		searchController.isActive = false
		super.viewWillDisappear(true)
	}
	
	
}

class SearchBarWithoutCancel: UISearchBar {
	override func layoutSubviews() {
		super.layoutSubviews()
		setShowsCancelButton(false, animated: false)
	}
}

class SearchControllerWithoutCancel: UISearchController, UISearchBarDelegate {
	
	lazy var _searchBar: SearchBarWithoutCancel = {
		[unowned self] in
		let result = SearchBarWithoutCancel(frame: .zero)
		result.delegate = self
		
		return result
		}()
	
	override var searchBar: UISearchBar {
		get {
			return _searchBar
		}
	}
}
