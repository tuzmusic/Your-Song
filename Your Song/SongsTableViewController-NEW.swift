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

class SongsTableViewController_NEW: RealmSearchViewController {
	
	func importSongs() {
		let importer = SongImporter()
		let fileName = "song list 2"
		if let songData = importer.getSongDataFromTSVFile(named: fileName) {
			importer.writeSongsToLocalRealm(songData: songData)
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Set the realm configuration
		let username = "tuzmusic@gmail.com"
		let password = "***REMOVED***"
		let localHTTP = URL(string:"http://54.208.237.32:9080")!
		
		SyncUser.logIn(with: .usernamePassword(username: username, password: password), server: localHTTP) {
			
			// Log in the user. If not, use local Realm config. If unable, return nil.
			user, error in
			guard let user = user else {
				print("Could not access server. Using local Realm.")
				self.importSongs()
				self.realmConfiguration = Realm.Configuration.defaultConfiguration
				return
			}
			
			DispatchQueue.main.async {
				// Open the online Realm
				let realmAddress = URL(string:"realm://54.208.237.32:9080/YourPianoBar/JonathanTuzman/")!
				let syncConfig = SyncConfiguration (user: user, realmURL: realmAddress)
				let configuration = Realm.Configuration(syncConfiguration: syncConfig)
				self.realmConfiguration = configuration
			}
		}
	}
	
	
	override func searchViewController(_ controller: RealmSearchViewController, cellForObject object: Object, atIndexPath indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		
		let item = object as! Song
		cell.textLabel?.text = item.title
		cell.detailTextLabel?.text = item.artist!.name
		
		return cell
	}
	
}
