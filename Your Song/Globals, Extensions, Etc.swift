//
//  Globals, Extensions, Etc.swift
//  Song Importer
//
//  Created by Jonathan Tuzman on 3/17/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import Foundation
import UIKit
import RealmSwift

let defaultsKey = "Your Piano Bar - Jonathan Tuzman - Songs"
var globalRealm: Realm!
var globalConfig: Realm.Configuration!

extension UITableViewController {
	open override func viewDidLayoutSubviews() {
		super.viewDidLayoutSubviews()
		tableView.contentInset = UIEdgeInsetsMake(self.topLayoutGuide.length, 0, self.bottomLayoutGuide.length, 0)
	}
}

func pr(_ thing: Any) {
	//print("\n***\n\(String(describing: thing))\n***\n")
	print("\n\(String(describing: thing))\n")
}

struct Storyboard {
	static let CategorySegue = "Category Segue"
	static let SongSegue = "Songs Segue"
	static let ArtistsSongsSegue = "Artist's Songs Segue"
	static let GenresArtistsSegue = "Genre's Artists Segue"
	static let BrowseSongsSegue = "Browse Songs Segue"
	static let SelectSongSegue = "Select Song Segue" 
}

struct Info {
	static let Artist = "artist"
	static let Song = "song"
	static let Genre = "genre"
}

extension UIColor {
	convenience init(rgb: UInt) {
		self.init(
			red: CGFloat((rgb & 0xFF0000) >> 16) / 255.0,
			green: CGFloat((rgb & 0x00FF00) >> 8) / 255.0,
			blue: CGFloat(rgb & 0x0000FF) / 255.0,
			alpha: CGFloat(1.0)
		)
	}
}

let ypbOrange = UIColor(rgb: 0xf19e2c)
let ypbBlack = UIColor(rgb: 0x514e50)

extension String {
	// I don't actually need this anymore, I needed it for populating what used to be the root of the table.
	var pluralCap: String {
		get {
			return self.lowercased() + "s"
		}
	}
}

// This isn't working, but, one day, maybe, whatever.
protocol CategoryBrowser {
	func viewDidLoad()
}

/* NOTES

Sometimes switching back to SONGS turns black!

Search songs, switch to artist, switch back to songs -- black! (search inside songs persists)
Clearing search, switching out and back, fixes it

*/
