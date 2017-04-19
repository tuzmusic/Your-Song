//
//  GenresTableViewController.swift
//  Song Browser
//
//  Created by Jonathan Tuzman on 3/17/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import UIKit

class OLDGenresTableViewController: CategoriesTableViewController {
	
	override func viewDidLoad() {
		category = Info.Genre
		super.viewDidLoad()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == Storyboard.GenresArtistsSegue,
			let artistsVC = segue.destination as? ArtistsTableViewController
		{
			if let genre = (sender as? UITableViewCell)?.textLabel?.text {
				artistsVC.title = genre
				let predicate = NSPredicate(format: "genre like %@", genre)
				let songsInGenre = songs.filter { predicate.evaluate(with: $0) }
				artistsVC.songs = songsInGenre
			}
		}
	}
}
