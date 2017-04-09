////
////  Song.swift
////  Your Song
////
////  Created by Jonathan Tuzman on 3/24/17.
////  Copyright © 2017 Jonathan Tuzman. All rights reserved.
////
//
//import Foundation
//import RealmSwift
//
//final class Song: Object {
//	dynamic var title = ""
//	var artist: Artist?
//	var genres = List<Genre>()
//	var decade: Int?
//	var requests: List<Request>?
//	
//	var popularity: Int { return self.requests?.count ?? 0 }
//	
//	class func newSong(named name: String, by artist: Artist, in genres: List<Genre>, from decade: Int?) -> Song {
//		let song = Song()
//		song.title = name
//		// check for existing artist
//		song.artist = artist
//		for genre in genres {
//			// check for existing genre
//			song.genres.append(genre)
//		}
//		song.decade = decade ?? nil
//		return song
//	}
//}
