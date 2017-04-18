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
	
	var selectedSong: Song!
	
	// This, or a global request
	var currentRequest = Request()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		// Set the realm configuration
		
		let username = "tuzmusic@gmail.com"
		let password = "***REMOVED***"
		let localHTTP = URL(string:"http://54.208.237.32:9080")!
		
		func importSongs() {
			let importer = SongImporter()
			let fileName = "song list 2"
			if let songData = importer.getSongDataFromTSVFile(named: fileName) {
				importer.writeSongsToLocalRealm(songData: songData)
			}
		}
		
		SyncUser.logIn(with: .usernamePassword(username: username, password: password), server: localHTTP) {
			
			// Log in the user. If not, use local Realm config. If unable, return nil.
			user, error in
			guard let user = user else {
				print("Could not access server. Using local Realm.")
				importSongs()
				self.realmConfiguration = Realm.Configuration.defaultConfiguration
				return
			}
			
			DispatchQueue.main.async {
				// Open the online Realm
				let realmAddress = URL(string:"realm://ec2-54-208-237-32.compute-1.amazonaws.com:9080/YourPianoBar/JonathanTuzman/")!
				let syncConfig = SyncConfiguration (user: user, realmURL: realmAddress)
				let configuration = Realm.Configuration(syncConfiguration: syncConfig)
				self.realmConfiguration = configuration
				self.refreshSearchResults()
				
				if self.realm.objects(Song.self).isEmpty {
					let offlineSongs = try! Realm().objects(Song.self)
					if offlineSongs.isEmpty { importSongs() }
					for song in offlineSongs {
						try! self.realm.write {
							_ = Song.createSong(from: song, in: self.realm)
						}
					}
					print("\(self.realm.objects(Song.self).count) songs in Realm. Online realm, right?")
				}
			}
		}
	}
	
	
	override func searchViewController(_ controller: RealmSearchViewController, cellForObject object: Object, atIndexPath indexPath: IndexPath) -> UITableViewCell {
		
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
//			requestVC.request.songObject = selectedSong
		}
	}
}
