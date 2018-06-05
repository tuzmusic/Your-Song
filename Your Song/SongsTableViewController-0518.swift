//
//  SongsTableViewController-0518.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 5/31/18.
//  Copyright © 2018 Jonathan Tuzman. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class SongsTableViewController_0518: BrowserTableViewController_0518 {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.type = Song.self
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let obj = object(at: indexPath)
		print(obj?.sortName)
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if extraSection == 1 {
			return section == 0 ? 2 : super.tableView(tableView, numberOfRowsInSection: section)
		}
		return super.tableView(tableView, numberOfRowsInSection: section)
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
		
		if extraSection == 1 && indexPath.section == 0 {
			cell.textLabel?.text = indexPath.row == 0 ? "Browse by Decade" : "Browse by Artist"
			cell.detailTextLabel?.text = nil
		} else {
			if let song = object(at: indexPath) as? Song {
				cell.textLabel?.text = song.title
				cell.detailTextLabel?.text = song.artist!.name
			}
		}
		return cell
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if basePredicate == nil, section == 1 {
			return "All Songs"
		}
		return nil
	}
	
	// TO-DO: Override didSelect (do this in browserVC becasue of adjIP?)
}
