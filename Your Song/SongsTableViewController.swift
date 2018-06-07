//
//  SongsTableViewController-0518.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 5/31/18.
//  Copyright © 2018 Jonathan Tuzman. All rights reserved.
//

import UIKit
import Realm
import RealmSwift

class SongsTableViewController: BrowserTableViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.type = Song.self
		self.extraRows = ["Browse by Decade", "Browse by Artist"]
		self.testPred = ("artist.name = %@", "Billy Joel")
	}
	
	override func viewDidAppear(_ animated: Bool) {   // a place for breakpoints and diagnostics
		super.viewDidAppear(true)
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		super.tableView(tableView, didSelectRowAt: indexPath)
		if let song = object(at: indexPath) as? Song, let form = requestFormDelegate {
			form.request.songObject = song
			form.songTextField.text = song.songDescription
			navigationController?.popToViewController(form, animated: true)
		} else if extraSection(contains: indexPath.section) {
			performSegue(withIdentifier: indexPath.row == 1 ? "SongsToArtists" : "SongsToDecades", sender: nil)
		}
	}
		
	override func tuzSearchController(_ searchCon: BrowserTableViewController, cellForNonHeaderRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
		if let song = object(at: indexPath) as? Song {
			cell.textLabel?.text = song.title
			cell.detailTextLabel?.text = song.artist!.name
		}
		return cell
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return extraSection == 1 && section == 1 ? "All Songs" : nil
	}
	
}
