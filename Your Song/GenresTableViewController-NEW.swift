//
//  GenresTableViewController-NEW.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 4/13/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import UIKit
import RealmSearchViewController
import RealmSwift

class GenresTableViewController_NEW: RealmSearchViewController {
	
	var selectedGenre: Genre!
	var genreName: String?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		//realmConfiguration = RealmSetup().setupConfig
		
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
				let realmAddress = URL(string:"realm://54.208.237.32:9080/YourPianoBar/JonathanTuzman/")!
				let syncConfig = SyncConfiguration (user: user, realmURL: realmAddress)
				let configuration = Realm.Configuration(syncConfiguration: syncConfig)
				self.realmConfiguration = configuration
			}
		}
		
	}
	
	override func searchViewController(_ controller: RealmSearchViewController, cellForObject object: Object, atIndexPath indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		
		let item = object as! Genre
		cell.textLabel?.text = item.name
		cell.detailTextLabel?.text = "\(item.songs.count) songs"
		
		return cell
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let artistsVC = segue.destination as? ArtistsTableViewController_NEW,
			let genreName = (sender as? UITableViewCell)?.textLabel?.text
		{
			selectedGenre = realm.objects(Genre.self).filter("name = %@", genreName).first
			// How to pass artist.songs instead of the destination VC having to look it up itself?
			artistsVC.basePredicate = NSPredicate(format: "name =  %@", selectedGenre.name)
			artistsVC.genreForArtists = selectedGenre			
		}
	}
}

