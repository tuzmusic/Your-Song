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

class SongsTableViewController: RealmSearchViewController {
	
	var selectedSong: Song!
	
	// This, or a global request
	var currentRequest = Request()

	override func searchViewController(_ controller: RealmSearchViewController, cellForObject object: Object, atIndexPath indexPath: IndexPath) -> UITableViewCell {

		//self.title = "All Songs (\(realm.objects(Song.self).count) songs)"

		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		
		selectedSong = object as! Song
		cell.textLabel?.text = selectedSong.title
		cell.detailTextLabel?.text = selectedSong.artist!.name
		
		return cell
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let requestVC = segue.destination as? CreateRequestTableViewController {
			currentRequest.songObject = selectedSong
			requestVC.request = currentRequest
		}
	}
}
