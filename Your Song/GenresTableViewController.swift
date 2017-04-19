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
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 2
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return section == 0 ? 1 : super.tableView(tableView, numberOfRowsInSection: section)
	}
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.section == 0 {
			let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
			cell.textLabel?.text = "All songs"
			cell.detailTextLabel?.text = "\(realm.objects(Song.self).count) songs"
		} else {
			return super.tableView(tableView, cellForRowAt: indexPath)
		}
		return UITableViewCell()
	}
	
	override func searchViewController(_ controller: RealmSearchViewController, cellForObject object: Object, atIndexPath indexPath: IndexPath) -> UITableViewCell {
		
		//self.title = "All Genres (\(realm.objects(Genre.self).count) genres)"
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		
		let genre = object as! Genre
		cell.textLabel?.text = genre.name
		
		cell.detailTextLabel?.text = "\(genre.songs.count) " + (genre.songs.count == 1 ? "song" : "song") + " by " + "\(genre.artists.count) " + (genre.artists.count == 1 ? "artist" : "artists")
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		if indexPath.section == 0 {
			performSegue(withIdentifier: Storyboard.AllSongsSegue, sender: nil)
		}
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

