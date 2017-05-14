//
//  DecadesTableViewController.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 5/11/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import UIKit
import RealmSwift
import RealmSearchViewController

class DecadesTableViewController: CategoryViewController {
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		if indexPath.section == 0 {
			let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
			cell.textLabel?.text = "All songs"
			cell.detailTextLabel?.text = "\(realm.objects(Song.self).count) songs"
			return cell
		} else {
			return super.tableView(tableView, cellForRowAt: indexPath)
		}
	}
	
	override func searchViewController(_ controller: RealmSearchViewController, cellForObject object: Object, atIndexPath indexPath: IndexPath) -> UITableViewCell {
		
		let cell = tableView.dequeueReusableCell(withIdentifier: "cell")!
		
		let decade = object as! Decade
		cell.textLabel?.text = decade.name
		
		cell.detailTextLabel?.text = "\(decade.songs.count) " + (decade.songs.count == 1 ? "song" : "song") + " by " + "\(decade.artists.count) " + (decade.artists.count == 1 ? "artist" : "artists")
		
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
		if segue.identifier! == Storyboard.GenresArtistsSegue,
			let artistsVC = segue.destination as? ArtistsTableViewController,
			let decade = sender as? Decade
		{
			artistsVC.decadeForArtists = decade
			artistsVC.basePredicate = NSPredicate(format: "name in %@", decade.artists.map { $0.name })
		}
	}
}
