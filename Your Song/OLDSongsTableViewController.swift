//
//  SongsTableViewController.swift
//  Song Importer
//
//  Created by Jonathan Tuzman on 3/16/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import UIKit

class OLDSongsTableViewController: BrowserTableViewController  {
	
	var shouldShowArtistSubtitle = true
	
	override func viewDidLoad() {
		super.viewDidLoad()
		category = Info.Song
	}
	
	// MARK: - Table view data source
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		
		if searchController.isActive && !searchController.searchBar.text!.isEmpty {
			return filteredSongs.count
		}
		return songs.count
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		
		var song = Song()
		if searchController.isActive && !searchController.searchBar.text!.isEmpty {
			song = filteredSongs[indexPath.row]
		} else {
			song = songs[indexPath.row]
		}
		
		cell.textLabel?.text = song.title
		cell.detailTextLabel?.text = shouldShowArtistSubtitle ? song.artist?.name : ""
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let song = searchController.isActive && !searchController.searchBar.text!.isEmpty
			? filteredSongs[indexPath.row] : songs[indexPath.row]
		
		if let requestForm = self.navigationController?.viewControllers.first(where: {$0 is CreateRequestTableViewController})
				as? CreateRequestTableViewController {
			//requestForm.request.songObject = song
			requestForm.request.songString = "\"\(song.title)\""
			if let artistName = song.artist?.name {
				requestForm.request.songString += " by \(artistName)"
			}
		}
		_ = navigationController?.popToRootViewController(animated: true)
	}
	
	override func shouldPerformSegue(withIdentifier identifier: String, sender: Any?) -> Bool {
		return false
	}
}

