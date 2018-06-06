
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

extension Realm {
	static func printUserInfo(in realm: Realm?) {
		// diagnostics
		let users = ["ed8b190c0679ec273f1597bd79108e54":"tuzmusic@gmail.com", "46297eaefc58a3378da0bf66f9b520eb":"jonathan"]
		if let id = realm?.configuration.syncConfiguration?.user.identity {
			print("user id: \(id)")
			if let name = users[id] {
				print("user: \(name)")
			} else {
				print("user not in my dictionary")
			}
		}
	}
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
	static let LoginToNewRequestSegue = "Login to New Request Segue"
	static let LoginToNewRequestSplitViewSegue = "Login to New Request Split View Segue"
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
		spinner.startAnimating()
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

	func isValidEmailAddress(alert: Bool = true) -> Bool {
		
		var isValid = true
		let emailRegEx = "[A-Z0-9a-z.-_]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,3}"
		
		do {
			let regex = try NSRegularExpression(pattern: emailRegEx)
			let nsString = self as NSString
			let results = regex.matches(in: self, range: NSRange(location: 0, length: nsString.length))
			
			if results.count == 0 {
				isValid = false
			}
		} catch let error as NSError {
			print("invalid regex: \(error.localizedDescription)")
			isValid = false
		}
		
		return isValid
	}
}

extension UIAlertController {
	class func basic(title: String?, message: String?) -> UIAlertController {
		let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let ok = UIAlertAction(title: "OK", style: .default, handler: nil)
		alert.addAction(ok)
		return alert
	}
}

/* NOTES

Sometimes switching back to SONGS turns black!

Search songs, switch to artist, switch back to songs -- black! (search inside songs persists)
Clearing search, switching out and back, fixes it

*/
