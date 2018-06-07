//
//  DecadesTableViewController-0518.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 6/5/18.
//  Copyright © 2018 Jonathan Tuzman. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class DecadesTableViewController: BrowserTableViewController {

	override func viewDidLoad() {
		super.viewDidLoad()
		self.type = Decade.self
		self.extraRows = ["All Songs", "All Artists"]
		self.testPred = ("name CONTAINS %@", "0s")
	}
	
	override func viewDidAppear(_ animated: Bool) {   // a place for breakpoints and diagnostics
		super.viewDidAppear(true)
	}
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		var sender: Any? = nil
		var id = "DecadesToSongs"
		if let decade = object(at: indexPath) as? Decade {
			sender = decade
		} else if extraSection(contains: indexPath.section) {
			sender = nil
			if indexPath.row == 1 {
				id = "DecadesToArtists"
			}
		}
		performSegue(withIdentifier: id, sender: sender)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		super.prepare(for: segue, sender: sender)
		if let songsVC = segue.destination as? SongsTableViewController {
			if let decade = sender as? Decade {
				songsVC.title = decade.name
				songsVC.basePredicate = NSPredicate(format: "decade = %@", decade)
			} else {
				// still go to songsVC, but don't add a predicate
			}
		}
		else if let artistsVC = segue.destination as? ArtistsTableViewController {
			// it's just all artists for now, no modification needed here
		}
	}
	
	override func tuzSearchController(_ searchCon: BrowserTableViewController, cellForNonHeaderRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
		if let decade = object(at: indexPath) as? Decade {
			cell.textLabel?.text = decade.name
			cell.detailTextLabel?.text = nil
			cell.accessoryType = .disclosureIndicator
		}
		return cell
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return extraSection == 1 && section == 1 ? "All Decades/Genres" : nil
	}
}
