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
		if song.title == "52Nd Street" {
			print("\(song.title), \(song.sortedName)")
		}
		cell.textLabel?.text = song.title
		cell.detailTextLabel?.text = song.artist!.name
		cell.detailTextLabel?.text = song.sortedName
		return cell
	}
		
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		super.tableView(tableView, didSelectRowAt: adjustedIndexPath(for: indexPath))
	}
	
	override func searchViewController(_ controller: RealmSearchViewController, didSelectObject anObject: Object, atIndexPath indexPath: IndexPath) {
		let song = anObject as! Song
		if let form = navigationController?.viewControllers.first as? CreateRequestTableViewController {
			form.songObject = song
		}
		navigationController?.popToRootViewController(animated: true)
	}
}
