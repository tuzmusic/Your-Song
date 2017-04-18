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
	
	override func searchViewController(_ controller: RealmSearchViewController, cellForObject object: Object, atIndexPath indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		
		let genre = object as! Genre
		cell.textLabel?.text = genre.name
		
		let songs = Array(genre.songs)
		var artists = [Artist]()
		songs.forEach {
			if !artists.contains($0.artist!) {
				artists.append(($0.artist!))
			}
		}
		
		cell.detailTextLabel?.text = "\(genre.songs.count) " + (genre.songs.count == 1 ? "song" : "song") + " by " + "\(artists.count) " + (artists.count == 1 ? "artist" : "artists")
		
		return cell
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let artistsVC = segue.destination as? ArtistsTableViewController_NEW,
			let genreName = (sender as? UITableViewCell)?.textLabel?.text
		{
			selectedGenre = realm.objects(Genre.self).filter("name = %@", genreName).first
			pr(selectedGenre)
			// How to pass artist.songs instead of the destination VC having to look it up itself?
			artistsVC.genreForArtists = selectedGenre
			artistsVC.basePredicate = NSPredicate(format: "name in %@", artistsVC.allArtistsArray)
		}
	}
}

