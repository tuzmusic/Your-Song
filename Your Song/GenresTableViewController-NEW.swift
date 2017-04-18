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
			pr(selectedGenre)
			// How to pass artist.songs instead of the destination VC having to look it up itself?
			artistsVC.genreForArtists = selectedGenre
			//artistsVC.basePredicate = NSPredicate(format: "self in %@", artistsVC.artistsInGenre)
			artistsVC.basePredicate = NSPredicate(format: "name in %@", artistsVC.allArtistsArray)
		}
	}
}

