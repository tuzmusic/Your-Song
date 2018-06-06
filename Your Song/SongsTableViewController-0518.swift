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

class SongsTableViewController_0518: BrowserTableViewController_0518 {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		self.type = Song.self
		self.extraRows = ["Browse by Decade", "Browse by Artist"]
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let obj = object(at: indexPath)
		print(obj?.sortName)
		tableView.deselectRow(at: indexPath, animated: true)
	}
	
	override func tuzSearchController(_ searchCon: BrowserTableViewController_0518, cellForNonHeaderRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
		if let song = object(at: indexPath) as? Song {
			cell.textLabel?.text = song.title
			cell.detailTextLabel?.text = song.artist!.name
		}
		return cell
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return extraSection == 0 && section == 1 ? "All Songs" : nil
	}
	
}
