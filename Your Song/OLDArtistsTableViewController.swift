//
//  ArtistsTableViewController.swift
//  Song Browser
//
//  Created by Jonathan Tuzman on 3/17/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import UIKit

class OLDArtistsTableViewController: CategoriesTableViewController {
	
	override func viewDidLoad() {
		category = Info.Artist
		super.viewDidLoad()
	}
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if segue.identifier == Storyboard.ArtistsSongsSegue,
			let songsVC = segue.destination as? OLDSongsTableViewController
		{
			if let artist = (sender as? UITableViewCell)?.textLabel?.text {
				songsVC.title = artist
				let predicate = NSPredicate(format: "\(Info.Artist) like[c] %@", artist)
				let songsByArtist = songs.filter { predicate.evaluate(with: $0) }
				songsVC.songs = songsByArtist
				songsVC.shouldShowArtistSubtitle = false
			}
		}
	}
}
