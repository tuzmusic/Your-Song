//
//  ArtistsTableViewController-NEW.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 4/16/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import UIKit
import RealmSearchViewController
import RealmSwift

class ArtistsTableViewController_NEW: RealmSearchViewController {
	
	var selectedArtist: Artist!
	var songs = [Song]()

	var genreForArtists: Genre?
	var artistsInGenre: [Artist]?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		if genreForArtists != nil {
			var artists = Set<Artist>()
			for song in realm.objects(Song.self).filter("genre = %@", genreForArtists!) {
				if song.genre == genreForArtists! {
					artists.insert(song.artist!)
				}
			}
			artistsInGenre = Array(artists)
		}		
		
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
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		
		
		if let artists = artistsInGenre {
			let item = artists[indexPath.row]
			cell.textLabel?.text = item.name
			cell.detailTextLabel?.text = "\(item.songs.count) songs"
		}
		else if let item = results?.object(at: UInt(indexPath.row)) {
			if let item = item as? Artist {
				cell.textLabel?.text = item.name
				cell.detailTextLabel?.text = "\(item.songs.count) songs"
			}
		}
		
		return cell

	}
	
	override func searchViewController(_ controller: RealmSearchViewController, cellForObject object: Object, atIndexPath indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		
		let item = object as! Artist
		cell.textLabel?.text = item.name
		cell.detailTextLabel?.text = "\(item.songs.count) songs"
		
		return cell
	}
	
//	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//		selectedArtist = Array(results)[indexPath.row]
//	}
	
	override func searchViewController(_ controller: RealmSearchViewController, didSelectObject anObject: Object, atIndexPath indexPath: IndexPath) {
//		selectedArtist = anObject as! Artist
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let songsVC = segue.destination as? SongsTableViewController_NEW,
			let artistName = (sender as? UITableViewCell)?.textLabel?.text
		{
			// How to pass artist.songs instead of the destination VC having to look it up itself?
			//	Note: selectedArtist has to be set here (using a text-based query) rather than in searchViewController(didSelectObject:atIndexPath:) because this gets called first.
			selectedArtist = realm.objects(Artist.self).filter("name = %@", artistName).first
			songsVC.basePredicate = NSPredicate(format: "artist.name =  %@", selectedArtist.name)
		}
	}
}
