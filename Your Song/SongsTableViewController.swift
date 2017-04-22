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
	
	override func viewDidLoad() {
//		realmConfiguration = YpbApp.ypbRealm.configuration
	}
	
	override func searchViewController(_ controller: RealmSearchViewController, cellForObject object: Object, atIndexPath indexPath: IndexPath) -> UITableViewCell {

		//self.title = "All Songs (\(realm.objects(Song.self).count) songs)"
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		
		let song = object as! Song
		cell.textLabel?.text = song.title
		cell.detailTextLabel?.text = song.artist!.name
		
		return cell
	}
	
	override func searchViewController(_ controller: RealmSearchViewController, didSelectObject anObject: Object, atIndexPath indexPath: IndexPath) {
		let song = anObject as! Song
		//YpbApp.currentRequest?.songObject = song
		if let form = navigationController?.viewControllers.first as? CreateRequestTableViewController {
			if let request = form.request {
				request.songObject = song
			} else {
				form.request = Request()
			}			
		}
		navigationController?.popToRootViewController(animated: true)
	}
}
