//
//  SongFinderTestsTableViewController.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 1/28/18.
//  Copyright © 2018 Jonathan Tuzman. All rights reserved.
//

import UIKit
import RealmSwift
import Realm

class SongFinderTestsTableViewController: UITableViewController {
	
	var finder = SongFinder()
	
	var testRequests = [String]()
	
	func createTestRequests() {
		testRequests.append("Just the Way You Are")
		testRequests.append("Just the Way You Are by Billy Joel")
		testRequests.append("Just the Way You Are by Bruno Mars")
		testRequests.append("Sweet Caroline - Neil Diamond")
		testRequests.append("Sweet Carolyn - Neil Diamond")
		testRequests.append("erhjklkjhg")
	}
	
	override func viewDidLoad() {
		createTestRequests()
	}
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return testRequests.count
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 2
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let requestString = testRequests[indexPath.section]
		let cell = tableView.dequeueReusableCell(withIdentifier: indexPath.row == 0 ? "stringCell" : "songCell")!
		
		switch indexPath.row {
		case 0:
			cell.textLabel?.text = requestString
		case 1:
			if let song = finder.songObject(for:  requestString) {
				cell.textLabel?.text = song.title
				cell.detailTextLabel?.text = song.artist.name
			} else {
				cell.textLabel?.text = "No song found"
				cell.detailTextLabel?.text = ""
			}
		default: break
		}
		return cell
	}
	
}

