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
		self.extraRows = ["Browse by Decade", "Browse by Artist"]
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let obj = object(at: indexPath)
		print(obj?.sortName)
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
		
		if !extraSection(contains: indexPath.section) {
			if let song = object(at: indexPath) as? Song {
				cell.textLabel?.text = song.title
				cell.detailTextLabel?.text = song.artist!.name
				return cell
			}
		}
		return super.tableView(tableView, cellForRowAt: indexPath)
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		if basePredicate == nil, section == 1 {
			return "All Songs"
		}
		return nil
	}
	
	// TO-DO: Override didSelect (do this in browserVC becasue of adjIP?)
}
