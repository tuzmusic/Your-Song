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

class ArtistsTableViewController: RealmSearchViewController {
	
	var selectedArtist: Artist!
	var songs = [Song]()
	
	var genreForArtists: Genre?
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return section == 0 ? 1 : super.tableView(tableView, numberOfRowsInSection: section)
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.section == 0 {
			let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
			if let genre = genreForArtists {
				cell.textLabel?.text = "All \(genre.name) songs"
				cell.detailTextLabel?.text = "\(genre.songs.count) songs"
			} else {
				cell.textLabel?.text = "All songs"
				cell.detailTextLabel?.text = "\(realm.objects(Song.self).count) songs"
			}
		} else {
			return super.tableView(tableView, cellForRowAt: indexPath)
		}
		return UITableViewCell()
	}
	
	override func searchViewController(_ controller: RealmSearchViewController, cellForObject object: Object, atIndexPath indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		
		if let genre = genreForArtists {
			// self.title = genre.name + " (\(genre.artists.count) artists)"
			let artist = genre.artists[indexPath.row]
			let songsByArtistInGenre = artist.songs.filter("genre = %@", genre)
			cell.textLabel?.text = artist.name
			cell.detailTextLabel?.text = "\(songsByArtistInGenre.count) \(genre.name)" + (songsByArtistInGenre.count == 1 ? " song" : " songs")
		} else {
			// self.title = "All Artists (\(realm.objects(Artist.self).count) artists)"
			let artist = object as! Artist
			cell.textLabel?.text = artist.name
			cell.detailTextLabel?.text = "\(artist.songs.count) songs"
		}
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.section == 0 {
			performSegue(withIdentifier: Storyboard.AllSongsSegue, sender: nil)
		}
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let songsVC = segue.destination as? SongsTableViewController {
			if segue.identifier == Storyboard.AllSongsSegue, let genre = genreForArtists {
				songsVC.basePredicate = NSPredicate(format: "genre = %@", genre)
			} else if segue.identifier == Storyboard.ArtistsSongsSegue,
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
}
