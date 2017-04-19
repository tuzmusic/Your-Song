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

class ArtistsTableViewController: RealmSearchViewController {
	
	var selectedArtist: Artist!
	var songs = [Song]()
	
	var genreForArtists: Genre?
	
	override func searchViewController(_ controller: RealmSearchViewController, cellForObject object: Object, atIndexPath indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		
		if let genre = genreForArtists {
			let artist = genre.artists[indexPath.row]
			let songsByArtistInGenre = artist.songs.filter("genre = %@", genre)
			cell.textLabel?.text = artist.name
			cell.detailTextLabel?.text = "\(songsByArtistInGenre.count) \(genre.name)" + (songsByArtistInGenre.count == 1 ? " song" : " songs")
		} else {
			let artist = object as! Artist
			cell.textLabel?.text = artist.name
			cell.detailTextLabel?.text = "\(artist.songs.count) songs"
		}
		return cell
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let songsVC = segue.destination as? SongsTableViewController,
			let artistName = (sender as? UITableViewCell)?.textLabel?.text
		{
			selectedArtist = realm.objects(Artist.self).filter("name = %@", artistName).first
			if let genre = genreForArtists {
				songsVC.basePredicate = NSPredicate(format: "artist = %@ AND genre = %@", selectedArtist, genre)
			} else {
				songsVC.basePredicate = NSPredicate(format: "artist = %@", selectedArtist)
			}
		}
	}
}
