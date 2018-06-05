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

class ArtistsTableViewController_0518: UITableViewController {

	
	var artists: Results<Artist>!
	var selectedArtist: Artist?
	
	// MARK: - Table view data source
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return section == 0 ? 1 : artists.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
		
		switch indexPath.section {
		case 0: cell.textLabel?.text = "All Songs"
		case 1: cell.textLabel?.text = artists[indexPath.row].name
		default: break
		}
		return cell
	}
	
	// MARK: - Table view delegate
	let identifier = "ArtistsToSongs"
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.section == 1 {
			selectedArtist = artists[indexPath.row]
		}
		performSegue(withIdentifier: identifier, sender: nil)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let songsVC = segue.destination as? SongsTableViewController_0518 {
//			songsVC.songs = 
		}
	}
}
