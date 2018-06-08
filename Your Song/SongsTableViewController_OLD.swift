//
//  SongsTableViewController-NEW.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 4/15/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import UIKit
import RealmSearchViewController
import RealmSwift

class SongsTableViewController_OLD: BrowserViewController_OLD {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Sort", style: .plain, target: self, action: #selector(sortSongs))
	}
	
	@objc func sortSongs() {
		let alert = UIAlertController(title: "Sort songs by...", message: nil, preferredStyle: .alert)
		
		alert.addAction(UIAlertAction(title: "Alphabetical (A to Z)", style: .default, handler: { _ in
			self.sortPropertyKey = "sortName"
			self.sortAscending = true
		}))
		alert.addAction(UIAlertAction(title: "Alphabetical (Z to A)", style: .default, handler: { _ in
			self.sortPropertyKey = "sortName"
			self.sortAscending = false
		}))
		/*
		alert.addAction(UIAlertAction(title: "Popularity (Most to Least)", style: .default, handler: { _ in
			self.sortPropertyKey = "popularity"
			self.sortAscending = true
		}))
		alert.addAction(UIAlertAction(title: "Popularity (Least to Most)", style: .default, handler: { _ in
			self.sortPropertyKey = "popularity"
			self.sortAscending = false
		}))
		*/
		alert.addAction(UIAlertAction(title: "cancel", style: .cancel, handler: nil))
		
		present(alert, animated: true)
	}
	
	override func searchViewController(_ controller: RealmSearchViewController, cellForObject object: Object, atIndexPath indexPath: IndexPath) -> UITableViewCell {

		let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
		let song = object as! Song

		cell.textLabel?.text = song.title
		cell.detailTextLabel?.text = song.artist!.name
		return cell
	}
		
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		// FYI: This calls the method from RSVC (no override in BrowserVC).
		// It's just here to convert the indexPath to adjustedIndexPath

		super.tableView(tableView, didSelectRowAt: adjustedIndexPath(for: indexPath))
	}
	
	override func searchViewController(_ controller: RealmSearchViewController, didSelectObject anObject: Object, atIndexPath indexPath: IndexPath) {
		let song = anObject as! Song
		let form = navigationController!.viewControllers.first as! CreateRequestTableViewController
		form.request.songObject = song
		form.songTextField.text = song.songDescription
		navigationController?.popToRootViewController(animated: true)
	}
}
