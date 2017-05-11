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

class GenresTableViewController: BrowserViewController {
	
	var selectedGenre: Genre!
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return super.numberOfSections(in: tableView) + 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if section != 0 {
			return super.tableView(tableView, numberOfRowsInSection: section - 1)
		}
		return 1
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.section == 0 {
			let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
			cell.textLabel?.text = "All songs"
			cell.detailTextLabel?.text = "\(realm.objects(Song.self).count) songs"
			return cell
		} else {
			var adjIndex = indexPath
			adjIndex.section -= 1
			return super.tableView(tableView, cellForRowAt: adjustedIndexPath(for: adjIndex))
		}
	}
	
	override func searchViewController(_ controller: RealmSearchViewController, cellForObject object: Object, atIndexPath indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
		
		let genre = object as! Genre
		cell.textLabel?.text = genre.name
		
		cell.detailTextLabel?.text = "\(genre.songs.count) " + (genre.songs.count == 1 ? "song" : "song") + " by " + "\(genre.artists.count) " + (genre.artists.count == 1 ? "artist" : "artists")
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.section == 0 {
			performSegue(withIdentifier: Storyboard.AllSongsSegue, sender: nil)
		} else {
			super.tableView(tableView, didSelectRowAt: indexPath)
		}
	}
	
	override func searchViewController(_ controller: RealmSearchViewController, didSelectObject anObject: Object, atIndexPath indexPath: IndexPath) {
		performSegue(withIdentifier: Storyboard.GenresArtistsSegue, sender: anObject)
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier! == Storyboard.ArtistsSongsSegue,
			let artistsVC = segue.destination as? ArtistsTableViewController,
			let genre = sender as? Genre
		{
			artistsVC.genreForArtists = genre
			artistsVC.basePredicate = NSPredicate(format: "name in %@", genre.artists.map { $0.name })
		}
	}
}

