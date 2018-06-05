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
		self.type = Song.self
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
		
		if basePredicate == nil && indexPath.section == 0 {
			cell.textLabel?.text = indexPath.row == 0 ? "Browse by Decade" : "Browse by Artist"
			cell.detailTextLabel?.text = nil
		} else {
			let item = results[adjustedIndexPath(for: indexPath).row]
			if let song = item as? Song {
				cell.textLabel?.text = song.title
				cell.detailTextLabel?.text = song.artist!.name
			}
		}
		return cell
	}
	
	// TO-DO: Override didSelect (do this in browserVC becasue of adjIP?)
}
