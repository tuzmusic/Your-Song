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

var hasLoaded = false

class ArtistsTableViewController_NEW: RealmSearchViewController {
	
	var selectedArtist: Artist!
	var songs = [Song]()

	var genreForArtists: Genre? {
		didSet {
			if genreForArtists != nil {
				var artists = Set<Artist>()
				for song in realm.objects(Song.self).filter("genre = %@", genreForArtists!) {
					if song.genre == genreForArtists! {
						artists.insert(song.artist!)
					}
				}
				pr(artists)
				artistsInGenre = Array(artists)
				pr(artistsInGenre)
			}
		}
	}
	
	var artistsInGenre = [Artist]()
	var allArtistsArray: [String] { return artistsInGenre.map { $0.name } }
	var allArtistsString: String { return (artistsInGenre.map { $0.name + " " }).joined() }
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	/*
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)		
		
		if !artistsInGenre.isEmpty {
			let item = artistsInGenre[indexPath.row]
			cell.textLabel?.text = item.name
			cell.detailTextLabel?.text = "\(item.songs.count) songs"
		}
		else {
			_ = super.tableView(tableView, cellForRowAt: indexPath)
		}
		return cell
	}
	*/
	
	override func searchViewController(_ controller: RealmSearchViewController, cellForObject object: Object, atIndexPath indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		
		if !artistsInGenre.isEmpty {
			let item = artistsInGenre[indexPath.row]
			cell.textLabel?.text = item.name
			cell.detailTextLabel?.text = "\(item.songs.count) songs"
		}
		else {
			let item = object as! Artist
			cell.textLabel?.text = item.name
			cell.detailTextLabel?.text = "\(item.songs.count) songs"
		}
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
