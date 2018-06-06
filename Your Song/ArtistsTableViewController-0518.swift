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

class ArtistsTableViewController_0518: BrowserTableViewController_0518 {
	override func viewDidLoad() {
		super.viewDidLoad()
		self.type = Artist.self
		self.extraRows = ["All Songs"]
		self.testPred = ("name CONTAINS %@", "The")
	}
	
	
	override func tuzSearchController(_ searchCon: BrowserTableViewController_0518, cellForNonHeaderRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
		if let artist = object(at: indexPath) as? Artist {
			cell.textLabel?.text = artist.name
			cell.detailTextLabel?.text = nil
		}
		return cell
	}
	
	override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
		return extraSection == 1 && section == 1 ? "All Artists" : nil
	}
	
}
