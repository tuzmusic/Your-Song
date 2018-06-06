//
//  ArtistsTableViewController-0518.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 5/31/18.
//  Copyright © 2018 Jonathan Tuzman. All rights reserved.
//

import UIKit
import RealmSwift
import Realm

class ArtistsTableViewController_0518: BrowserTableViewController_0518 {
	override func viewDidLoad() {
		super.viewDidLoad()
		self.type = Artist.self
		self.extraRows = ["All Songs"]
		self.testPred = ("name CONTAINS %@", "The")
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		var sender: Any? = nil
		if let artist = object(at: indexPath) as? Artist {
			sender = artist
		} else if extraSection(contains: indexPath.section) {
			sender = nil
		}
		performSegue(withIdentifier: "ArtistsToSongs", sender: sender)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let songsVC = segue.destination as? SongsTableViewController_0518 {
			songsVC.realm = realm
			songsVC.requestFormDelegate = requestFormDelegate
			if let artist = sender as? Artist {
				songsVC.basePredicate = NSPredicate(format: "artist.name = %@", artist.name)
			}
		}
	}
	
	override func tuzSearchController(_ searchCon: BrowserTableViewController_0518, cellForNonHeaderRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
		if let artist = object(at: indexPath) as? Artist {
			cell.textLabel?.text = artist.name
			cell.detailTextLabel?.text = nil
		}
		return cell
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return extraSection == 1 && section == 1 ? "All Artists" : nil
	}
	
}
