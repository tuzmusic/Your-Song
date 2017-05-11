//
//  Genre.swift
//  Your Song
//
//  Created by Jonathan Tuzman on 3/24/17.
//  Copyright © 2017 Jonathan Tuzman. All rights reserved.
//

import Foundation
import RealmSwift

class Genre: BrowserCategory {
	
	//var songs = LinkingObjects(fromType: Song.self, property: "genre")
	var songs = LinkingObjects(fromType: Song.self, property: className().lowercased())
	
	var artists = List<Artist>()
//	var artists: [Artist] {
//		var artists = [Artist]()
//		self.songs.forEach {
//			if !artists.contains($0.artist!) {
//				artists.append(($0.artist!))
//			}
//		}
//		return artists
//	}
	
	var decades = List<Decade>()
//
//	var decades: [Decade] {
//		var decades = [Decade]()
//		self.songs.forEach {
//			if let firstDecade = $0.decades.first {
//				if !decades.contains(firstDecade) {
//					decades.append(firstDecade)
//				}
//			}
//		}
//		return decades
//	}
}
