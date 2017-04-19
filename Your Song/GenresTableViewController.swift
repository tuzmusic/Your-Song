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


class GenresTableViewController: RealmSearchViewController {
	
	var selectedGenre: Genre!
	
	override func searchViewController(_ controller: RealmSearchViewController, cellForObject object: Object, atIndexPath indexPath: IndexPath) -> UITableViewCell {
		
		//self.title = "All Genres (\(realm.objects(Genre.self).count) genres)"
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		
		let genre = object as! Genre
		cell.textLabel?.text = genre.name
		
		cell.detailTextLabel?.text = "\(genre.songs.count) " + (genre.songs.count == 1 ? "song" : "song") + " by " + "\(genre.artists.count) " + (genre.artists.count == 1 ? "artist" : "artists")
		
		return cell
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let artistsVC = segue.destination as? ArtistsTableViewController,
			let genreName = (sender as? UITableViewCell)?.textLabel?.text
		{
			selectedGenre = realm.objects(Genre.self).filter("name = %@", genreName).first
			artistsVC.genreForArtists = selectedGenre
			artistsVC.basePredicate = NSPredicate(format: "name in %@", selectedGenre.artists.map { $0.name })
		}
	}
}

