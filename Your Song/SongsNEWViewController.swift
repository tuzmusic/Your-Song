//
//  SongsNEWViewController.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 4/26/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import UIKit
import RealmSwift
import RealmSearchViewController

class SongsNEWViewController: RealmSearchViewController {
	
	override func searchViewController(_ controller: RealmSearchViewController, cellForObject object: Object, atIndexPath indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		
		let song = object as! Song
		cell.textLabel?.text = song.title
		cell.detailTextLabel?.text = song.artist!.name
		
		return cell

	}
}
