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

var globalConfig: Realm.Configuration!

struct RealmConstants {
	static let ec2ip = "54.205.63.24"
	static let ec2ipDash = ec2ip.replacingOccurrences(of: ".", with: "-")
	static let amazonAddress = "ec2-\(ec2ipDash).compute-1.amazonaws.com:9080"
	static let localHTTP = URL(string:"http://" + ec2ip)!
	static let publicDNS = URL(string:"http://" + amazonAddress)!
	static let realmAddress = URL(string:"realm://" + amazonAddress + "/YourPianoBar/JonathanTuzman/")!
	
	static let userCred = SyncCredentials.usernamePassword(
		username: "realm-admin", password: "")
	static let tuzCred = SyncCredentials.usernamePassword(
		username: "tuzmusic", password: "***REMOVED***")
	
	// NOTE: I've also created a "tuzmusic" user with my standard PW, also an admin. See what happens with this...
}

func timeSince(time: Date) -> String {
    
    let now = Date()
    let secondsAgo = DateInterval(start: time, end: now).duration
    let minutesAgo = secondsAgo / 60
    let hoursAgo = Int(minutesAgo / 60)
    let timeAgo = "\(hoursAgo)h \(Int(minutesAgo.truncatingRemainder(dividingBy: 60)))m ago"
    
    return timeAgo
}

func pr(_ thing: Any) {
	print("\n\(String(describing: thing))\n")
}

struct Storyboard {
	static let CategorySegue = "Category Segue"
	static let SongSegue = "Songs Segue"
	static let ArtistsSongsSegue = "Artist's Songs Segue"
	static let GenresArtistsSegue = "Genre's Artists Segue"
	static let BrowseSongsSegue = "Browse Songs Segue"
	static let SelectSongSegue = "Select Song Segue"
	static let AllSongsSegue = "All Songs Segue"
	static let LoginSegue = "Log In Segue"
}


extension UITextView {
	func reset(with placeholder: String, color: UIColor) {
		self.text = placeholder
		self.textColor = color
	}
}

extension UIView {
	func addNewSpinner() -> UIActivityIndicatorView {
		let spinner = UIActivityIndicatorView()
		spinner.frame.origin.x = self.frame.midX - 20
		spinner.frame.origin.y = self.frame.midY - 20
		spinner.frame.size = CGSize(width: 40, height: 40)
		spinner.hidesWhenStopped = true
		spinner.activityIndicatorViewStyle = .whiteLarge
		spinner.color = .lightGray
		self.addSubview(spinner)
		return spinner
	}
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
