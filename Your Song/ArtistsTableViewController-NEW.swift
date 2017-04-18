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
	
	var artistsInGenre = [Artist]()
	var allArtistsArray: [String] { return artistsInGenre.map { $0.name } }
	
	var genreForArtists: Genre? {
		didSet {
			genreForArtists?.songs.forEach {
				if !artistsInGenre.contains($0.artist!) {
					artistsInGenre.append($0.artist!)
				}
			}
		}
	}
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
	}
	
	override func searchViewController(_ controller: RealmSearchViewController, cellForObject object: Object, atIndexPath indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		
		if !artistsInGenre.isEmpty {
			let artist = artistsInGenre[indexPath.row]
			let songsByArtistInGenre = artist.songs.filter("genre = %@", genreForArtists!)
			
			cell.textLabel?.text = artist.name
			cell.detailTextLabel?.text = "\(songsByArtistInGenre.count) \(genreForArtists!.name)" + (songsByArtistInGenre.count == 1 ? " song" : " songs")
		} else {
			let artist = object as! Artist
			cell.textLabel?.text = artist.name
			cell.detailTextLabel?.text = "\(artist.songs.count) songs"
		}
		return cell
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let songsVC = segue.destination as? SongsTableViewController_NEW,
			let artistName = (sender as? UITableViewCell)?.textLabel?.text
		{
			// How to pass artist.songs instead of the destination VC having to look it up itself?
			selectedArtist = realm.objects(Artist.self).filter("name = %@", artistName).first
			songsVC.basePredicate = NSPredicate(format: "artist.name =  %@", selectedArtist.name)
			if let genre = genreForArtists {
				songsVC.basePredicate = NSCompoundPredicate(
					andPredicateWithSubpredicates: [songsVC.basePredicate!,
					                                NSPredicate(format: "genre =  %@", genre)])
			}
		}
	}
}
