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

class SongsTableViewController: BrowserViewController {
	
	override func searchViewController(_ controller: RealmSearchViewController, cellForObject object: Object, atIndexPath indexPath: IndexPath) -> UITableViewCell {

		let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
		let song = object as! Song
		cell.textLabel?.text = song.title
		cell.detailTextLabel?.text = song.artist!.name
		
		return cell	
	}
	
	
	override func searchViewController(_ controller: RealmSearchViewController, didSelectObject anObject: Object, atIndexPath indexPath: IndexPath) {
		
		// With only letters handled by indexes, the indexPath here is wrong.
		
		let song = anObject as! Song
		if let form = navigationController?.viewControllers.first as? CreateRequestTableViewController {
			form.songObject = song
		}
		navigationController?.popToRootViewController(animated: true)
	}
}
