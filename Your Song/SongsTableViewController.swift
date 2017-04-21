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
		
		let song = object as! Song
		cell.textLabel?.text = song.title
		cell.detailTextLabel?.text = song.artist!.name
		
		return cell
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		var songs = [Song]()
		if let predicate = basePredicate {
			songs = Array(realm.objects(Song.self).filter(predicate))
		} else {
			songs = Array(realm.objects(Song.self))
		}
		
		if let requestVC = segue.destination as? CreateRequestTableViewController,
			let row = tableView.indexPathForSelectedRow?.row
		{
			currentRequest.songObject = songs[row]
			pr(currentRequest.songObject!.title)
			requestVC.request = currentRequest
		}
	}
}
