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

class ArtistsTableViewController: BrowserViewController {
	
	var selectedArtist: Artist!
	var songs = [Song]()
	
	var genreForArtists: Genre?
	var decadeForArtists: Decade?
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return super.numberOfSections(in: tableView) + 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section != 0 {
			return super.tableView(tableView, numberOfRowsInSection: section - 1)
		}
		return 1
	}

	// This is just for the "All songs" row. Has nothing to do with whether there's a genre.
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.section == 0 {
			let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
			if let genre = genreForArtists {
				cell.textLabel?.text = "All \(genre.name) songs"
				cell.detailTextLabel?.text = "\(genre.songs.count) songs"
			} else {
				cell.textLabel?.text = "All songs"
				cell.detailTextLabel?.text = "\(realm.objects(Song.self).count) songs"
			}
			return cell
		} else {
			var adjIndex = indexPath
			adjIndex.section -= 1
			return super.tableView(tableView, cellForRowAt: adjustedIndexPath(for: adjIndex))
		}
	}
	
	override func searchViewController(_ controller: RealmSearchViewController, cellForObject object: Object, atIndexPath indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
		
		// These two should be able to be genericized (in an actual generic function), the predicate just needs to be accounted for in an argument.
		if let genre = genreForArtists {
			let artist = genre.artists[indexPath.row]
			let songsByArtistInGenre = artist.songs.filter("genre = %@", genre)
			cell.textLabel?.text = artist.name
			cell.detailTextLabel?.text = "\(songsByArtistInGenre.count) \(genre.name)" + (songsByArtistInGenre.count == 1 ? " song" : " songs")
		} else if let decade = decadeForArtists {
			let artist = decade.artists[indexPath.row]
			let songsByArtistInDecade = artist.songs.filter("decade = %@", decade)
			cell.textLabel?.text = artist.name
			cell.detailTextLabel?.text = "\(songsByArtistInDecade.count) \(decade.name)" + (songsByArtistInDecade.count == 1 ? " song" : " songs")
		} else {
			let artist = object as! Artist
			cell.textLabel?.text = artist.name
			cell.detailTextLabel?.text = "\(artist.songs.count) songs"
		}
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.section == 0 {
			performSegue(withIdentifier: Storyboard.AllSongsSegue, sender: nil)
		} else {
			var adjIndex = indexPath
			adjIndex.row += 1
			super.tableView(tableView, didSelectRowAt: adjIndex)
		}
	}
	
	override func searchViewController(_ controller: RealmSearchViewController, didSelectObject anObject: Object, atIndexPath indexPath: IndexPath) {
		print(anObject)
		performSegue(withIdentifier: Storyboard.ArtistsSongsSegue, sender: anObject)
	}
		
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let songsVC = segue.destination as? SongsTableViewController {
			switch segue.identifier! {
			case Storyboard.AllSongsSegue:
				if let genre = genreForArtists {
					songsVC.basePredicate = NSPredicate(format: "genre = %@", genre)
				} else if let decade = decadeForArtists {
					songsVC.basePredicate = NSPredicate(format: "decade = %@", decade)
				}
			case Storyboard.ArtistsSongsSegue:
				if let artist = sender as? Artist {
					if let genre = genreForArtists {
						songsVC.basePredicate = NSPredicate(format: "artist = %@ AND genre = %@", artist, genre)
					} else if let decade = decadeForArtists {
						songsVC.basePredicate = NSPredicate(format: "artist = %@ AND decade = %@", artist, decade)
					} else {
						songsVC.basePredicate = NSPredicate(format: "artist = %@", artist)
					}
				}
			default: break
			}
		}
	}
}
