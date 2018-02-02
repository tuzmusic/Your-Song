//
//  SongFinder.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 1/27/18.
//  Copyright © 2018 Jonathan Tuzman. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
/* NOTES
can't get the "like" (or "LIKE") operator in the predicate to work, or even launch without crashing
*/
class SongFinder {
	var realm = try? Realm()
	
	var string = ""
	
	fileprivate func searchByFullString() -> Song? {
		if let song = realm?.objects(Song.self).filter(NSPredicate(format:"title =[cd] %@", string)).first {
			return song
		} else if let song = realm?.objects(Song.self).filter("songDescription =[cd] %@", string).first {
			return song
		}
		
		// TO-DO: Manage the possibility of multiple results
		
		return nil
	}
	
	fileprivate func searchBySeparatingWithBy() -> Song? {
		
		var sepString = [String]()
		let separators = ["by", "-"]
		for item in separators {
			if string.contains(" \(item) ") {
				sepString = string.components(separatedBy: item)
				break
			}
		}
		guard !sepString.isEmpty else { return nil }
		
		let possibleTitle = sepString[0]
		let possibleArtist = sepString[1]
		
		if let songs = realm?.objects(Song.self).filter("title =[cd] %@", possibleTitle) {
			switch songs.count {
			case 0: return nil
			case 1: return songs.first!
			default:  // count > 1
				if let songByArtist = songs.filter("artist.name =[cd] %@", possibleArtist).first {
					return songByArtist
				}
			}
		}
		
		return nil
	}

	func songObject(for requestString: String) -> Song? {
		self.string = requestString
		if let song = searchByFullString() {
			return song
		} else if let song = searchBySeparatingWithBy() {
			return song
		}
		return nil
	}
}
