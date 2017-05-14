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

class ArtistsTableViewController: CategoryViewController {
	
	var genreForArtists: Genre?
	var decadeForArtists: Decade?

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		// This is just for the "All songs" row(s). Has nothing to do with whether there's a genre.
		if indexPath.section == 0 {
			let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
			if let genre = genreForArtists {
				cell.textLabel?.text = "All \(genre.name) songs"
				cell.detailTextLabel?.text = "\(genre.songs.count) songs"
			} else if let decade = decadeForArtists {
				cell.textLabel?.text = "All \(decade.name) songs"
				cell.detailTextLabel?.text = "\(decade.songs.count) songs"
			}  else {
				cell.textLabel?.text = "All songs"
				cell.detailTextLabel?.text = "\(realm.objects(Song.self).count) songs"
			}
			return cell
		} else {
			return super.tableView(tableView, cellForRowAt: indexPath)
		}
	}
	
	override func searchViewController(_ controller: RealmSearchViewController, cellForObject object: Object, atIndexPath indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
		
		// These two should be able to be genericized (in an actual generic function), the predicate just needs to be accounted for in an argument.
		let artist = object as! Artist
		cell.textLabel?.text = artist.name

		if let genre = genreForArtists {
			let songsByArtistInGenre = artist.songs.filter("genre = %@", genre)
			cell.detailTextLabel?.text = "\(songsByArtistInGenre.count) \(genre.name)" + (songsByArtistInGenre.count == 1 ? " song" : " songs")
		}
		if let decade = decadeForArtists {
			let songsByArtistInDecade = artist.songs.filter("decade = %@", decade)
			cell.detailTextLabel?.text = "\(songsByArtistInDecade.count) \(decade.name)" + (songsByArtistInDecade.count == 1 ? " song" : " songs")
		} else {
			cell.detailTextLabel?.text = "\(artist.songs.count)" + (artist.songs.count == 1 ? " song" : " songs")
		}
		return cell
	}
	
	override func searchViewController(_ controller: RealmSearchViewController, didSelectObject anObject: Object, atIndexPath indexPath: IndexPath) {
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
					var predicates = [NSPredicate(format: "artist = %@", artist)]
					if let decade = decadeForArtists { predicates.append(NSPredicate(format: "decade = %@", decade)) }
					if let genre = genreForArtists { predicates.append(NSPredicate(format: "genre = %@", genre)) }
					songsVC.basePredicate = NSCompoundPredicate(andPredicateWithSubpredicates: predicates)
				}
			default: break
			}
		}
	}
}
